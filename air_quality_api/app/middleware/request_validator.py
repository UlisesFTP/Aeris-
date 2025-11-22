"""
Request validation middleware using Marshmallow.
Validates and sanitizes incoming requests to prevent invalid data and injection attacks.
"""
from marshmallow import Schema, fields, ValidationError, validates, validates_schema
from flask import jsonify
from functools import wraps

class CoordinatesSchema(Schema):
    """Schema for validating latitude and longitude coordinates"""
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

class LocationSchema(CoordinatesSchema):
    """Schema for location data with name"""
    name = fields.String(required=True, validate=lambda x: 1 <= len(x) <= 200)
    user_id = fields.String(required=True, validate=lambda x: 1 <= len(x) <= 100)

class UserIdentifierSchema(Schema):
    """Schema for user identification"""
    user_id = fields.String(required=True, validate=lambda x: 1 <= len(x) <= 100)

class AdviceRequestSchema(Schema):
    """Schema for Gemini advice requests"""
    weather = fields.String(required=True, validate=lambda x: len(x) <= 500)
    aqi = fields.Dict(required=True)
    language = fields.String(missing='es', validate=lambda x: x in ['en', 'es'])
    
    @validates('aqi')
    def validate_aqi(self, value):
        if 'aqi' not in value:
            raise ValidationError("AQI data must include 'aqi' field")
        if not isinstance(value['aqi'], (int, float)):
            raise ValidationError("AQI value must be a number")
        if not 1 <= value['aqi'] <= 6:
            raise ValidationError("AQI must be between 1 and 6")

class WeatherAdviceSchema(Schema):
    """Schema for weather-specific advice requests"""
    temp = fields.Float(required=True)
    condition = fields.String(required=True, validate=lambda x: len(x) <= 200)
    min_temp = fields.Float(required=True)
    max_temp = fields.Float(required=True)
    language = fields.String(missing='es', validate=lambda x: x in ['en', 'es'])
    
    @validates_schema
    def validate_temperatures(self, data, **kwargs):
        if data['min_temp'] > data['max_temp']:
            raise ValidationError("min_temp cannot be greater than max_temp")

class LocationVisitSchema(CoordinatesSchema):
    """Schema for recording location visits"""
    user_id = fields.String(required=True, validate=lambda x: 1 <= len(x) <= 100)
    location_name = fields.String(required=True, validate=lambda x: 1 <= len(x) <= 200)

class HistoryQuerySchema(Schema):
    """Schema for history queries"""
    user_id = fields.String(required=True, validate=lambda x: 1 <= len(x) <= 100)
    days = fields.Integer(missing=7, validate=lambda x: 1 <= x <= 30)

def validate_request(schema_class):
    """
    Decorator to validate incoming request data against a schema.
    
    Usage:
        @validate_request(CoordinatesSchema)
        def my_endpoint():
            # request has been validated
            pass
    
    Args:
        schema_class: Marshmallow Schema class to validate against
    
    Returns:
        Decorated function that validates request before execution
    """
    def decorator(f):
        @wraps(f)
        def decorated_function(*args, **kwargs):
            schema = schema_class()
            try:
                # Try JSON first
                if request.is_json:
                    validated_data = schema.load(request.get_json())
                # Then query parameters
                else:
                    validated_data = schema.load(request.args.to_dict())
                
                # Attach validated data to request for use in endpoint
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
    """
    Sanitize a string value by removing potentially dangerous characters.
    
    Args:
        value: String to sanitize
        max_length: Maximum allowed length
    
    Returns:
        Sanitized string
    """
    if not isinstance(value, str):
        return ""
    
    # Remove null bytes and limit length
    sanitized = value.replace('\0', '').strip()[:max_length]
    
    return sanitized
