#!/usr/bin/python

from flask import Flask, request
from flask_restful import Resource, Api


app = Flask(__name__)
api = Api(app)

class Helloworld(Resource):
    def get(self):
        return 'Hello World'

api.add_resource(Helloworld, '/')

if __name__ == '__main__':
    app.run(host = '0.0.0.0', port='5002')
