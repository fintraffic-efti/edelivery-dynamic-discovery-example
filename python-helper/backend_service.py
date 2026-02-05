#!/usr/bin/env python3
"""
Backend Service implementation for Harmony Access Point.
Simple implementation that just logs raw SOAP XML messages.
"""

import logging
from lxml import etree
from wsgiref.simple_server import make_server

# Configure logging
logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s - %(name)s - %(levelname)s - %(message)s'
)
logger = logging.getLogger(__name__)


class SimpleBackendService:
    """Simple WSGI application that logs all SOAP requests as raw XML"""

    def __init__(self):
        self.request_count = 0

    def __call__(self, environ, start_response):
        """Handle WSGI request"""
        method = environ.get('REQUEST_METHOD', '')
        path = environ.get('PATH_INFO', '')

        # Handle SOAP POST request
        if method == 'POST':
            return self.handle_soap_request(environ, start_response)

        # Handle other requests
        start_response('404 Not Found', [('Content-Type', 'text/plain')])
        return [b'Not Found']

    def handle_soap_request(self, environ, start_response):
        """Handle SOAP request by logging the raw XML"""
        try:
            # Read the request body
            content_length = int(environ.get('CONTENT_LENGTH', 0))
            request_body = environ['wsgi.input'].read(content_length)

            self.request_count += 1

            # Log the raw request
            logger.info("=" * 80)
            logger.info(f"SOAP Request #{self.request_count}")
            logger.info(f"Content-Length: {content_length} bytes")
            logger.info(f"Content-Type: {environ.get('CONTENT_TYPE', 'unknown')}")
            logger.info("-" * 80)

            # Try to pretty-print the XML
            try:
                tree = etree.fromstring(request_body)
                pretty_xml = etree.tostring(tree, pretty_print=True, encoding='unicode')
                logger.info("SOAP XML (pretty-printed):")
                logger.info(pretty_xml)
            except Exception as e:
                # If parsing fails, log the raw content
                logger.info("Raw SOAP content (could not parse as XML):")
                try:
                    logger.info(request_body.decode('utf-8'))
                except:
                    logger.info(f"[Binary content, {len(request_body)} bytes]")

            logger.info("=" * 80)

            # Return a simple SOAP response (empty)
            soap_response = b'''<?xml version="1.0" encoding="UTF-8"?>
<soap:Envelope xmlns:soap="http://www.w3.org/2003/05/soap-envelope">
    <soap:Body/>
</soap:Envelope>'''

            start_response('200 OK', [
                ('Content-Type', 'application/soap+xml; charset=utf-8'),
                ('Content-Length', str(len(soap_response)))
            ])
            return [soap_response]

        except Exception as e:
            logger.error(f"Error handling SOAP request: {str(e)}", exc_info=True)

            # Return SOAP fault
            fault = f'''<?xml version="1.0" encoding="UTF-8"?>
<soap:Envelope xmlns:soap="http://www.w3.org/2003/05/soap-envelope">
    <soap:Body>
        <soap:Fault>
            <soap:Code>
                <soap:Value>soap:Receiver</soap:Value>
            </soap:Code>
            <soap:Reason>
                <soap:Text xml:lang="en">Server Error: {str(e)}</soap:Text>
            </soap:Reason>
        </soap:Fault>
    </soap:Body>
</soap:Envelope>'''.encode('utf-8')

            start_response('500 Internal Server Error', [
                ('Content-Type', 'application/soap+xml; charset=utf-8'),
                ('Content-Length', str(len(fault)))
            ])
            return [fault]


def main():
    """Main entry point"""
    logger.info("Starting Simple Backend Service (XML Logger)...")

    app = SimpleBackendService()

    host = '0.0.0.0'
    port = 8080
    
    logger.info(f"Backend Service listening on {host}:{port}")
    logger.info("This service logs all incoming SOAP messages as raw XML")

    server = make_server(host, port, app)

    try:
        server.serve_forever()
    except KeyboardInterrupt:
        logger.info("Shutting down...")


if __name__ == '__main__':
    main()
