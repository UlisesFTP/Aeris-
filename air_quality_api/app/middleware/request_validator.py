"""
Request validation middleware using Marshmallow.
Validates and sanitizes incoming requests.
"""
from marshmallow import Schema, fields, ValidationError, validates
from flask import jsonify, request
from functools import wraps


class CoordinatesSchema(Schema):
    """Schema for validating latitude and longitude coordinates."""
    lat = fields.Float(required=True)
    lon = fields.Float(required=True)

    @validates('lat')
    def validate_latitude(self, value):
        if not -90 <= value <= 90:
            raise ValidationError("Latitude must be between -90 and 90")

    @validates('lon')
    def validate_longitude(self, value):
        if not -180 <= value <= 180:
            raise ValidationError("Longitude must be between -180 and 180")


def validate_request(schema_class):
    """
    Decorator to validate incoming request data against a Marshmallow schema.

    Usage:
        @validate_request(CoordinatesSchema)
        def my_endpoint():
            # request.validated_data is available here
            pass
    """
    def decorator(f):
        @wraps(f)
        def decorated_function(*args, **kwargs):
            schema = schema_class()
            try:
                if request.is_json:
                    validated_data = schema.load(request.get_json())
                else:
                    validated_data = schema.load(request.args.to_dict())
                request.validated_data = validated_data
            except ValidationError as err:
                return jsonify({
                    "error": "Validation failed",
                    "details": err.messages
                }), 400
            return f(*args, **kwargs)
        return decorated_function
    return decorator


def sanitize_string(value, max_length=200):
    """Remove null bytes and limit length of a string."""
    if not isinstance(value, str):
        return ""
    return value.replace('\0', '').strip()[:max_length]
