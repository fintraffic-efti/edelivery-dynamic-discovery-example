#!/usr/bin/env python3
"""
Send an eDelivery message to harmony-party-a wsplugin API.
"""

import argparse
import base64
import datetime
import os
import requests
import sys
from requests.auth import HTTPBasicAuth


def send_message(
    from_party_id: str,
    from_party_type: str,
    service: str,
    action: str,
    payload: str,
    from_role: str,
    original_sender: str,
    final_recipient: str,
    wsplugin_url: str,
    conversation_id: str = None,
    service_type: str = None
):
    """Send an eDelivery message via wsplugin API.

    Args:
        from_party_id: Sender party identifier
        from_party_type: Sender party type (URN)
        service: Service name
        action: Action name
        payload: Message payload (will be base64-encoded)
        from_role: Sender role (defaults to ebMS default role)
        original_sender: Original sender identifier
        final_recipient: Final recipient identifier
        wsplugin_url: URL of the wsplugin API endpoint
        conversation_id: Optional conversation identifier
        service_type: Optional service type
    """

    # Base64-encode the payload
    encoded_payload = base64.b64encode(payload.encode('utf-8')).decode('ascii')

    # Build optional elements
    conversation_id_elem = f'<eb:ConversationId>{conversation_id}</eb:ConversationId>' if conversation_id else ''
    service_type_attr = f' type="{service_type}"' if service_type else ''

    #                     <eb:Property name="originalSender" type="urn:oasis:names:tc:ebcore:partyid-type:unregistered">party-a</eb:Property>
    # Construct SOAP envelope with proper ebMS header
    soap_envelope = f"""<?xml version="1.0" encoding="UTF-8"?>
<soap:Envelope xmlns:soap="http://schemas.xmlsoap.org/soap/envelope/"
               xmlns:eb="http://docs.oasis-open.org/ebxml-msg/ebms/v3.0/ns/core/200704/"
               xmlns:wsplugin="http://eu.domibus.wsplugin/">
    <soap:Header>
        <eb:Messaging>
            <eb:UserMessage>
                <eb:PartyInfo>
                    <eb:From>
                        <eb:PartyId type="{from_party_type}">{from_party_id}</eb:PartyId>
                        <eb:Role>{from_role}</eb:Role>
                    </eb:From>
                </eb:PartyInfo>
                <eb:CollaborationInfo>
                    <eb:Service{service_type_attr}>{service}</eb:Service>
                    <eb:Action>{action}</eb:Action>
                    {conversation_id_elem}
                </eb:CollaborationInfo>
                <eb:MessageProperties>
                    <eb:Property name="originalSender" type="urn:oasis:names:tc:ebcore:partyid-type:unregistered:some-scheme">{original_sender}</eb:Property>
                    <eb:Property name="finalRecipient" type="urn:oasis:names:tc:ebcore:partyid-type:unregistered:some-scheme">{final_recipient}</eb:Property>
                </eb:MessageProperties>
                <eb:PayloadInfo>
                    <eb:PartInfo href="cid:message">
                        <eb:PartProperties>
                            <eb:Property name="MimeType">text/xml</eb:Property>
                        </eb:PartProperties>
                    </eb:PartInfo>
                </eb:PayloadInfo>
            </eb:UserMessage>
        </eb:Messaging>
    </soap:Header>
    <soap:Body>
        <wsplugin:submitRequest>
            <payload payloadId="cid:message" contentType="text/xml">
                <value>{encoded_payload}</value>
            </payload>
        </wsplugin:submitRequest>
    </soap:Body>
</soap:Envelope>"""

    headers = {
        "Content-Type": "text/xml;charset=UTF-8",
        "SOAPAction": ""
    }

    try:
        # Disable SSL warnings for self-signed certificates
        import urllib3
        urllib3.disable_warnings(urllib3.exceptions.InsecureRequestWarning)

        response = requests.post(
            wsplugin_url,
            data=soap_envelope,
            headers=headers,
            verify=False  # Self-signed certificate in local setup
        )

        response.raise_for_status()
        print("Message sent successfully!")
        print(f"Response status: {response.status_code}")
        print(f"Response: {response.text}")
        return response

    except requests.exceptions.RequestException as e:
        print(f"Error sending message: {e}", file=sys.stderr)
        if hasattr(e, 'response') and e.response is not None:
            print(f"Response body: {e.response.text}", file=sys.stderr)
        sys.exit(1)


if __name__ == "__main__":
    parser = argparse.ArgumentParser(
        description="Send an eDelivery message to harmony wsplugin API"
    )

    parser.add_argument(
        "--from-party",
        dest="from_party",
        required=True,
        help="Sender party identifier (e.g., 'party-a')"
    )

    args = parser.parse_args()

    # Define hardcoded parameters based on from_party value
    from_party = args.from_party

    # Default configuration (can be customized based on from_party if needed)
    config = {
        "from_party_id": from_party,
        "from_party_type": "urn:oasis:names:tc:ebcore:partyid-type:unregistered",
        "from_role": "http://docs.oasis-open.org/ebxml-msg/ebms/v3.0/ns/core/200704/initiator",
        "service": "some-process-value",
        "service_type": "some-process-scheme",
        "action": "some-action-scheme::some-action-value",
        "payload": "<message>Test eDelivery message</message>",
        "conversation_id": f"some-conversation-{datetime.datetime.now().strftime('%Y-%m-%d-%H-%M-%S')}",
    }

    if from_party == "party-a":
        config["original_sender"] = "dd_participant_a"
        config["final_recipient"] = "dd_participant_b"
        config["wsplugin_url"] = "https://harmony-party-a:8443/services/wsplugin"
    elif from_party == "party-b":
        config["original_sender"] = "dd_participant_b"
        config["final_recipient"] = "dd_participant_a"
        config["wsplugin_url"] = "https://harmony-party-b:8443/services/wsplugin"
    else:
        print(f"Unknown from-party: {from_party}", file=sys.stderr)
        sys.exit(1)

    send_message(
        from_party_id=config["from_party_id"],
        from_party_type=config["from_party_type"],
        from_role=config["from_role"],
        service=config["service"],
        service_type=config["service_type"],
        action=config["action"],
        payload=config["payload"],
        original_sender=config["original_sender"],
        final_recipient=config["final_recipient"],
        wsplugin_url=config["wsplugin_url"],
        conversation_id=config["conversation_id"]
    )
