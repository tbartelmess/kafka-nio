#===----------------------------------------------------------------------===//
#
# This source file is part of the KafkaNIO open source project
#
# Copyright © 2020 Thomas Bartelmess.
# Licensed under Apache License v2.0
#
# See LICENSE.txt for license information
#
# SPDX-License-Identifier: Apache-2.0
#
#===----------------------------------------------------------------------===//

import json
import re
from pathlib import Path, PosixPath
import textwrap


def key_name(x):
    name = x['name']
    name = name.replace('Request', '')
    return name

def camel_case(string: str):
    return string[0].lower() + string[1:]

def swiftize_field_name(string: str):
    return camel_case(string).replace('Id', 'ID')

def indent(string, level):
    return '\n'.join([("    " *  level) + line for line in string.splitlines()])


enum_conversions = {
    "ErrorCode": "ErrorCode",
    "IsolationLevel": "IsolationLevel",
    "CoordinatorType": "CoordinatorType",
    "ApiKey": "APIKey",
    "KeyType": "CoordinatorType"
}

class AbstractGenerator:
    type_translations = {
        "string": "String",
        "int64": "Int64",
        "int32": "Int32",
        "int16": "Int16",
        "int8": "Int8",
        "records": "ByteBuffer",
        "bytes": "[UInt8]",
        "bool": "Bool",
        "float64": "Float64",
        "LeaderAndIsrPartitionState": "[UInt8]",
        "UpdateMetadataPartitionState": "[UInt8]"
    }
    definition = {}

    @property
    def is_custom_type(self):
        return self.base_type[0] not in self.type_translations.values()

    @property
    def is_array(self):
        return self.base_type[1]

    @property
    def base_type(self):
        java_type = self.definition['type']
        is_array = '[]' in java_type
        base_type = java_type.replace('[]', '')
        if base_type in self.type_translations:
            base_type = self.type_translations[base_type]

        return base_type, is_array


    @property
    def first_available_version(self) -> int:
        versions = self.definition['versions']
        if '+' in versions:
            versions = versions.replace('+', '')
            return int(versions)
        if '-' in versions:
            return int(versions.split('-')[0])
        return int(versions)

    @property
    def last_available_version(self) -> int:
        versions = self.definition['versions']
        if '-' in versions:
            return int(versions.split('-')[1])
        if '+' in versions:
            return None
        return int(versions)

    @property
    def nullable_versions(self) -> int:
        versions = self.definition.get('nullableVersions')
        if not versions:
            return None
        return int(versions.replace('+', ''))

    def write_function(self):
        return "write"

    @property
    def needs_length_encoding(self):
        return self.definition['type'] == "string" or self.definition['type'] == "bytes" or self.is_array

    @property
    def extra_read_parameters(self):
        if self.needs_length_encoding:
            return "lengthEncoding: lengthEncoding"
        return ""

    @property
    def extra_write_parameters(self):
        if self.needs_length_encoding:
            return ", lengthEncoding: lengthEncoding"
        return ""

    def value_write(self):
        api_version_argument = ""
        try_keyword = ""

        if self.is_custom_type:
            api_version_argument = ", apiVersion: apiVersion"
            try_keyword = "try "

        return f"{try_keyword}buffer.write({swiftize_field_name(self.definition['name'])}{api_version_argument}{self.extra_write_parameters})"

    def value_read(self):
        read_command = "buffer.read("
        read_command += self.extra_read_parameters
        read_command += ")"
        if self.is_custom_type:
            read_command = f"buffer.read(apiVersion: apiVersion{self.extra_write_parameters})"
        return f"{swiftize_field_name(self.definition['name'])} = try {read_command}"


    def generate_write(self):
        output = ""
        conditions = []
        if self.first_available_version != 0:
            conditions.append(f"apiVersion >= {self.first_available_version}")
        if self.last_available_version is not None:
            conditions.append(f"apiVersion <= {self.last_available_version}")
        if conditions:
            conditions_string = " && ".join(conditions)
            output += f"if {conditions_string} " + "{\n"
            if not self.nullable_versions:
                output += indent(f"guard let {swiftize_field_name(self.definition['name'])} = self.{swiftize_field_name(self.definition['name'])} else ", 1) + "{\n"
                output += indent("throw KafkaError.missingValue",2) + "\n"
                output += indent("}",1) + "\n"
            output += indent(self.value_write(), 1) + "\n"
            output += "}"
        else:
            output += self.value_write()
        return output

    def generate_read(self):
        output = ""
        conditions = []
        if self.first_available_version != 0:
            conditions.append(f"apiVersion >= {self.first_available_version}")
        if self.last_available_version is not None:
            conditions.append(f"apiVersion <= {self.last_available_version}")
        if conditions:
            conditions_string = " && ".join(conditions)
            output += f"if {conditions_string} " + "{\n"
            output += indent(self.value_read(), 1) + "\n"
            output += "} else { \n"
            output += indent(f"{swiftize_field_name(self.definition['name'])} = nil", 1) + "\n"
            output += "}\n"
        else:
            output += self.value_read()
        return output

    def generate_read_tagged_fields(self):
        output = ""
        if self.flexible_versions is None:
            return ""
        output += f"if apiVersion >= {self.flexible_versions} " + "{\n"
        output += indent("taggedFields = try buffer.read()",1) + "\n"
        output += "}\n"
        return output

    def generate_write_tagged_fields(self):
        output = ""
        if self.flexible_versions is None:
            return ""
        output += indent(f"if apiVersion >= {self.flexible_versions} " + "{", 1) + "\n"
        output += indent("buffer.write(taggedFields)", 2) + "\n"
        output += indent("}", 1) + "\n"
        return output

    @property
    def fields_required_length_encoding(self):
        generate_length_encoding = False

        for field in self.definition.get('fields') or []:
            generator = APIFieldGenerator(field, self.flexible_versions)
            generate_length_encoding = generate_length_encoding or generator.needs_length_encoding
        return generate_length_encoding

    def generate_length_encoding_declaration(self):
        if self.flexible_versions is not None:
            return f"let lengthEncoding: IntegerEncoding = (apiVersion >= {self.flexible_versions}) ? .varint : .bigEndian\n"
        else:
            return "let lengthEncoding: IntegerEncoding = .bigEndian\n"

class APITypeGenerator(AbstractGenerator):
    def __init__(self, name, fields, flexible_versions):
        self.name = name
        self.fields = fields
        self.flexible_versions = flexible_versions

    def generate_nested_types(self, struct_type):
        for field in self.fields:
            generator = APIFieldGenerator(field)
            output += indent(generator.generate_types(struct_type), 1)

    @property
    def has_string(self):
        for field in self.fields:
            if field.get('type') == 'string':
                return True
        return False


        return generate_length_encoding

    @property
    def fields_required_length_encoding(self):
        generate_length_encoding = False

        for field in self.fields or []:
            generator = APIFieldGenerator(field, self.flexible_versions)
            generate_length_encoding = generate_length_encoding or generator.needs_length_encoding
        return generate_length_encoding

    def generate_type(self, struct_type):
        struct_type_name = None
        if struct_type == "request":
            struct_type_name = "KafkaRequestStruct"
        elif struct_type == "response":
            struct_type_name = "KafkaResponseStruct"
        output = "struct " + self.name + ": " + struct_type_name + " {\n"
        for field in self.fields:
            generator = APIFieldGenerator(field, self.flexible_versions)
            types = generator.generate_types(struct_type)
            if types:
                output += indent(types, 1) + "\n"
        output += "\n"

        for field in self.fields:
            generator = APIFieldGenerator(field, self.flexible_versions)
            output += indent(generator.generate_field(), 1)
        output += "\n"

        if struct_type == "request" and self.flexible_versions is not None:
            output += indent("let taggedFields: [TaggedField] = []", 1) + "\n"
        # Reading
        if struct_type == "response":
            output += indent("init(from buffer: inout ByteBuffer, apiVersion: APIVersion) throws {", 1) + "\n"


            if self.fields_required_length_encoding:
                output += indent(self.generate_length_encoding_declaration(), 2) + "\n"
            for field in self.fields:
                generator = APIFieldGenerator(field, self.flexible_versions)
                output += indent(generator.generate_read(), 2) + "\n"
            if self.flexible_versions is not None:
                output += indent(f"if apiVersion >= {self.flexible_versions} " + "{", 2)+ "\n"
                output += indent("let _ : [TaggedField] = try buffer.read()", 3) + "\n"
                output += indent("}",2)+ "\n"
            output += indent("}", 1) + "\n"

        # Writing
        if struct_type == "request":
            output += indent("func write(into buffer: inout ByteBuffer, apiVersion: APIVersion) throws {",1) + "\n"
            if self.fields_required_length_encoding:
                output += indent(self.generate_length_encoding_declaration(),2) + "\n"
            for field in self.fields:
                generator = APIFieldGenerator(field, self.flexible_versions)
                output += indent(generator.generate_write(), 2) + "\n"
            output += indent(self.generate_write_tagged_fields(), 1) +"\n"
            output += indent("\n}",1)
        output += "\n}\n\n"

        # Init
        init_args = [APIFieldGenerator(field, self.flexible_versions).init_argument() for field in self.fields]
        output = "init(apiVersion: APIVersion, " + ", ".join(init_args) + ") {\n"
        output += indent("self.apiVersion = apiVersion",1) + "\n"
        if self.flexible_versions is not None:
            output += indent("self.taggedFields = []", 1) + "\n"
        for field in self.fields:
            if 'taggedVersions' in field:
                continue
            field_generator = APIFieldGenerator(field, self.flexible_versions)
            output += indent(field_generator.init_assignment(), 1) + "\n"
        output += "}"
        return output

        output += "}"
        return output


class APIFieldGenerator(AbstractGenerator):

    def __init__(self, definition, flexible_versions):
        self.definition = definition
        self.flexible_versions = flexible_versions

    @property
    def name(self):
        return self.definition['name']

    @property
    def type(self):
        print(self.name)
        if self.name in enum_conversions:
            return enum_conversions[self.name] + ('?' if self.is_optional else '')

        base_type, is_array = self.base_type

        final_type = ""
        if is_array:
            final_type = f"[{base_type}]"
        else:
            final_type = base_type
        return final_type + ('?' if self.is_optional else '')

    @property
    def docstring(self):
        return "/// {self.about}"

    def generate_types(self, struct_type):
        if self.is_custom_type:
            return APITypeGenerator(self.base_type[0], self.definition['fields'], self.flexible_versions).generate_type(struct_type)
        return None


    @property
    def is_optional(self):
        return self.first_available_version != 0 or self.last_available_version is not None or self.nullable_versions is not None

    def generate_field(self):
        output = f"""
        /// {self.definition.get('about')}
        let {swiftize_field_name(self.name)}: {self.type}
        """
        return textwrap.dedent(output)

    def init_argument(self):
        return f"{swiftize_field_name(self.name)}: {self.type}"

    def init_assignment(self):
        return f"self.{swiftize_field_name(self.name)} = {swiftize_field_name(self.name)}"




class APIMessageGenerator(AbstractGenerator):
    def __init__(self, definition_file: Path):
        with open(definition_file, 'r') as f:
            lines = f.readlines()
            self.definition = json.loads('\n'.join([line for line in lines if '//' not in line]))
    @property
    def flexible_versions(self) -> int:
        versions = self.definition.get('flexibleVersions')
        if versions == "none":
            return None
        if not versions:
            return None
        return int(versions.replace('+', ''))

    @property
    def struct_name(self):
        return self.definition['name']

    @property
    def has_string(self):

        for field in self.definition.get('fields', []):
            if field.get('type') == 'string':
                return True
        return False

    @property
    def api_key_name(self):
        name = self.definition['name'].replace('Request', '').replace('Response', '')
        return camel_case(name)



    def generate_write(self):
        output = "func write(into buffer: inout ByteBuffer) throws {\n"
        if self.fields_required_length_encoding:
            output += indent(self.generate_length_encoding_declaration(), 1) + "\n"
        output += indent("writeHeader(into: &buffer, version: apiKey.requestHeaderVersion(for: apiVersion))",1) + "\n"
        for field in self.definition['fields']:
            # For now tagged fields are skipped
            if 'taggedVersions' in field:
                continue
            field_generator = APIFieldGenerator(field, self.flexible_versions)
            output += indent(field_generator.generate_write(), 1) + "\n"
        if self.flexible_versions is not None:
            output += indent(f"if apiVersion >= {self.flexible_versions} " + "{", 1) + "\n"
            output += indent("buffer.write(taggedFields)", 2) + "\n"
            output += indent("}", 1) + "\n"
        output += "}"
        return output

    def generate_read(self):
        output = "init(from buffer: inout ByteBuffer, responseHeader: KafkaResponseHeader, apiVersion: APIVersion) throws { \n"

        if self.fields_required_length_encoding:
            output += indent(self.generate_length_encoding_declaration(), 1) + "\n"
        output += indent("self.apiVersion = apiVersion",1) + "\n"
        output += indent("self.responseHeader = responseHeader",1) + "\n"
        for field in self.definition['fields']:
            # Skip tagged fields for now
            if 'taggedVersions' in field:
                continue
            field_generator = APIFieldGenerator(field, self.flexible_versions)
            output += indent(field_generator.generate_read(), 1) + "\n"
        if self.flexible_versions is not None:
            output += indent(f"if apiVersion >= {self.flexible_versions} " + "{", 1) + "\n"
            output += indent("taggedFields = try buffer.read()", 2) + "\n"
            output += indent("} else {", 1) + "\n"
            output += indent("taggedFields = []", 2) + "\n"
            output += indent("}", 1) + "\n"
        output += "}"
        return output

    def generate_custom_types(self, struct_type: str):
        output = []
        for field in self.definition['fields']:
            field_generator = APIFieldGenerator(field, self.flexible_versions)
            types = field_generator.generate_types(struct_type)
            if types:
                 output.append(types)
        return "\n\n".join(output) + "\n"


    def generate_init(self):
        init_args = [APIFieldGenerator(field, self.flexible_versions).init_argument() for field in self.definition['fields']]
        output = "init(apiVersion: APIVersion, responseHeader: KafkaResponseHeader, " + ", ".join(init_args) + ") {\n"
        output += indent("self.apiVersion = apiVersion",1) + "\n"
        output += indent("self.responseHeader = responseHeader",1) + "\n"
        if self.flexible_versions is not None:
            output += indent("self.taggedFields = []", 1) + "\n"
        for field in self.definition['fields']:
            if 'taggedVersions' in field:
                continue
            field_generator = APIFieldGenerator(field, self.flexible_versions)
            output += indent(field_generator.init_assignment(), 1) + "\n"
        output += "}"
        return output


    def generate_request(self):
        output =  "struct " + self.struct_name + ": KafkaRequest { \n"
        output += indent(self.generate_custom_types("request"), 1) + "\n"
        output += indent(f"let apiKey: APIKey = .{self.api_key_name}", 1) + "\n"
        output += indent("let apiVersion: APIVersion", 1) + "\n"
        output += indent("let clientID: String?", 1) + "\n"
        output += indent("let correlationID: Int32", 1) + "\n"
        if self.flexible_versions is not None:
            output += indent("let taggedFields: [TaggedField] = []", 1) + "\n"
        for field in self.definition['fields']:
            # Skip tagged fields for now
            if 'taggedVersions' in field:
                continue
            field_generator = APIFieldGenerator(field, self.flexible_versions)
            output += indent(field_generator.generate_field(),1) + "\n"
        output += "\n\n" + indent(self.generate_write(), 1) + "\n"

        output += "}\n"
        return output

    def generate_response(self):
        output = "struct " + self.struct_name + ": KafkaResponse { \n"
        output += indent(self.generate_custom_types("response"), 1) + "\n"
        output += indent(f"let apiKey: APIKey = .{self.api_key_name}", 1) + "\n"
        output += indent("let apiVersion: APIVersion", 1) + "\n"
        output += indent("let responseHeader: KafkaResponseHeader", 1) + "\n"

        for field in self.definition['fields']:
            # Skip tagged fields for now
            if 'taggedVersions' in field:
                continue
            field_generator = APIFieldGenerator(field, self.flexible_versions)
            output += indent(field_generator.generate_field(), 1) + "\n"
        if self.flexible_versions is not None:
            output += indent("let taggedFields: [TaggedField]", 1) + "\n"

        output += "\n\n" + indent(self.generate_read(), 1) + "\n"
        output += "\n\n" + indent(self.generate_init(), 1) + "\n"
        output += "}"
        return output

header = """//===----------------------------------------------------------------------===//
//
// This source file is part of the KafkaNIO open source project
//
// Copyright © 2020 Thomas Bartelmess.
// Licensed under Apache License v2.0
//
// See LICENSE.txt for license information
//
// SPDX-License-Identifier: Apache-2.0
//
//===----------------------------------------------------------------------===//
//
// This file is auto generated from the Kafka Protocol definition. DO NOT EDIT.

import NIO


"""

definitions_directory = Path(__file__).parents[0] / "Definitions"
generated_directory = Path(__file__).parents[0] / "../Sources/KafkaNIO/Messages"
for file in definitions_directory.iterdir():
    print(f"file: {file.stem}")
    if file.suffix != ".json":
        continue
    generator = APIMessageGenerator(file)
    output = generated_directory / f"{file.stem}.swift"
    with open(output, 'w') as f:
        f.write(header)
        if file.stem.endswith("Request"):
            f.write(generator.generate_request())
        if file.stem.endswith("Response"):
            f.write(generator.generate_response())

