insert into SMP_USER (ID, USERNAME, ACTIVE, APPLICATION_ROLE, EMAIL, CREATED_ON, LAST_UPDATED_ON)
values (1, 'system', 1, 'SYSTEM_ADMIN', 'system@mail-example.local', NOW(), NOW());


insert into SMP_CREDENTIAL (ID, FK_USER_ID, CREDENTIAL_ACTIVE, CREDENTIAL_NAME, CREDENTIAL_VALUE, CREDENTIAL_TYPE,
                            CREDENTIAL_TARGET, CREATED_ON, LAST_UPDATED_ON, EXPIRE_ON)
values (2,
        1,
        1,
        'system',
        -- ./smp-password-hash.sh local-pwd-123
        '$2a$10$7v1.XllzNEF6S5iRwhr71.ZSCUmIqD5Qs/RKQCgNWdKJdbI9oigqK',
        'USERNAME_PASSWORD',
        'UI',
        NOW(),
        NOW(),
           -- Set expiry date to future so that password change is not enforced upon first login
        DATE_ADD(NOW(), INTERVAL 1 YEAR));

INSERT INTO SMP_DOCUMENT
VALUES (1, '2026-02-02 08:24:49', '2026-02-02 08:25:34', 1, 'text/xml', 'dd_participant_b', NULL, FALSE, NULL),
       (2, '2026-02-02 08:26:01', '2026-02-02 08:27:01', 1, 'text/xml', 'some-action-value', NULL, FALSE, NULL),
       (3, '2026-02-02 08:34:05', '2026-02-02 08:34:45', 1, 'text/xml', 'dd_participant_a', NULL, FALSE, NULL),
       (4, '2026-02-02 08:35:20', '2026-02-02 08:36:06', 1, 'text/xml', 'some-action-value', NULL, FALSE, NULL);

INSERT INTO SMP_DOCUMENT_VERSION
VALUES (1, '2026-02-02 08:24:49', '2026-02-02 08:25:34',
        _binary '<?xml version="1.0" encoding="UTF-8" standalone="yes"?><ServiceGroup xmlns="http://docs.oasis-open.org/bdxr/ns/SMP/2016/05" xmlns:ns2="http://www.w3.org/2000/09/xmldsig#"><ParticipantIdentifier scheme="${resource.identifier.scheme}">${resource.identifier.value}</ParticipantIdentifier><ServiceMetadataReferenceCollection/></ServiceGroup>',
        'RETIRED', 1, 1),
       (2, '2026-02-02 08:25:31', '2026-02-02 08:25:34',
        _binary '<?xml version="1.0" encoding="UTF-8" standalone="yes"?><ServiceGroup xmlns="http://docs.oasis-open.org/bdxr/ns/SMP/2016/05" xmlns:ns2="http://www.w3.org/2000/09/xmldsig#"><ParticipantIdentifier scheme="urn:oasis:names:tc:ebcore:partyid-type:unregistered:some-scheme">dd_participant_b</ParticipantIdentifier><ServiceMetadataReferenceCollection/></ServiceGroup>',
        'DRAFT', 2, 1),
       (3, '2026-02-02 08:26:01', '2026-02-02 08:27:01',
        _binary '<?xml version="1.0" encoding="UTF-8" standalone="yes"?><ServiceMetadata xmlns="http://docs.oasis-open.org/bdxr/ns/SMP/2016/05" xmlns:ns2="http://www.w3.org/2000/09/xmldsig#"><ServiceInformation><ParticipantIdentifier scheme="${resource.identifier.scheme}">${resource.identifier.value}</ParticipantIdentifier><DocumentIdentifier scheme="${subresource.identifier.scheme}">${subresource.identifier.value}</DocumentIdentifier><ProcessList><Process><ProcessIdentifier scheme="[test-schema]">[test-value]</ProcessIdentifier><ServiceEndpointList><Endpoint transportProfile="bdxr-transport-ebms3-as4-v1p0"><EndpointURI>https://mypage.eu</EndpointURI><Certificate>Q2VydGlmaWNhdGUgZGF0YSA=</Certificate><ServiceDescription>Service description for partners </ServiceDescription><TechnicalContactUrl>www.best-page.eu</TechnicalContactUrl></Endpoint></ServiceEndpointList></Process></ProcessList></ServiceInformation></ServiceMetadata>',
        'RETIRED', 1, 2),
       (4, '2026-02-02 08:26:59', '2026-02-02 08:27:01',
        _binary '<ServiceMetadata xmlns="http://docs.oasis-open.org/bdxr/ns/SMP/2016/05"><ServiceInformation><ParticipantIdentifier scheme="urn:oasis:names:tc:ebcore:partyid-type:unregistered:some-scheme">dd_participant_b</ParticipantIdentifier><DocumentIdentifier scheme="some-action-scheme">some-action-value</DocumentIdentifier><ProcessList><Process><ProcessIdentifier scheme="some-process-scheme">some-process-value</ProcessIdentifier><ServiceEndpointList><Endpoint transportProfile="bdxr-transport-ebms3-as4-v1p0"><EndpointURI>https://harmony-party-b:8443/services/msh</EndpointURI><Certificate><!-- placeholder party-b ap cert --></Certificate><ServiceDescription></ServiceDescription><TechnicalContactUrl></TechnicalContactUrl></Endpoint></ServiceEndpointList></Process></ProcessList></ServiceInformation></ServiceMetadata>',
        'DRAFT', 2, 2),
       (5, '2026-02-02 08:34:05', '2026-02-02 08:34:45',
        _binary '<?xml version="1.0" encoding="UTF-8" standalone="yes"?><ServiceGroup xmlns="http://docs.oasis-open.org/bdxr/ns/SMP/2016/05" xmlns:ns2="http://www.w3.org/2000/09/xmldsig#"><ParticipantIdentifier scheme="${resource.identifier.scheme}">${resource.identifier.value}</ParticipantIdentifier><ServiceMetadataReferenceCollection/></ServiceGroup>',
        'RETIRED', 1, 3),
       (6, '2026-02-02 08:34:42', '2026-02-02 08:34:45',
        _binary '<?xml version="1.0" encoding="UTF-8" standalone="yes"?><ServiceGroup xmlns="http://docs.oasis-open.org/bdxr/ns/SMP/2016/05" xmlns:ns2="http://www.w3.org/2000/09/xmldsig#"><ParticipantIdentifier scheme="urn:oasis:names:tc:ebcore:partyid-type:unregistered:some-scheme">dd_participant_a</ParticipantIdentifier><ServiceMetadataReferenceCollection/></ServiceGroup>',
        'DRAFT', 2, 3),
       (7, '2026-02-02 08:35:20', '2026-02-02 08:36:06',
        _binary '<?xml version="1.0" encoding="UTF-8" standalone="yes"?><ServiceMetadata xmlns="http://docs.oasis-open.org/bdxr/ns/SMP/2016/05" xmlns:ns2="http://www.w3.org/2000/09/xmldsig#"><ServiceInformation><ParticipantIdentifier scheme="${resource.identifier.scheme}">${resource.identifier.value}</ParticipantIdentifier><DocumentIdentifier scheme="${subresource.identifier.scheme}">${subresource.identifier.value}</DocumentIdentifier><ProcessList><Process><ProcessIdentifier scheme="[test-schema]">[test-value]</ProcessIdentifier><ServiceEndpointList><Endpoint transportProfile="bdxr-transport-ebms3-as4-v1p0"><EndpointURI>https://mypage.eu</EndpointURI><Certificate>Q2VydGlmaWNhdGUgZGF0YSA=</Certificate><ServiceDescription>Service description for partners </ServiceDescription><TechnicalContactUrl>www.best-page.eu</TechnicalContactUrl></Endpoint></ServiceEndpointList></Process></ProcessList></ServiceInformation></ServiceMetadata>',
        'RETIRED', 1, 4),
       (8, '2026-02-02 08:36:04', '2026-02-02 08:36:06',
        _binary '<ServiceMetadata xmlns="http://docs.oasis-open.org/bdxr/ns/SMP/2016/05"><ServiceInformation><ParticipantIdentifier scheme="urn:oasis:names:tc:ebcore:partyid-type:unregistered:some-scheme">dd_participant_a</ParticipantIdentifier><DocumentIdentifier scheme="some-action-scheme">some-action-value</DocumentIdentifier><ProcessList><Process><ProcessIdentifier scheme="some-process-scheme">some-process-value</ProcessIdentifier><ServiceEndpointList><Endpoint transportProfile="bdxr-transport-ebms3-as4-v1p0"><EndpointURI>https://harmony-party-a:8443/services/msh</EndpointURI><Certificate><!-- placeholder party-a ap cert --></Certificate><ServiceDescription></ServiceDescription><TechnicalContactUrl></TechnicalContactUrl></Endpoint></ServiceEndpointList></Process></ProcessList></ServiceInformation></ServiceMetadata>',
        'DRAFT', 2, 4);

INSERT INTO `SMP_DOMAIN`
VALUES (1, '2026-02-02 08:22:45', '2026-02-02 08:23:19', NULL, 'somedomaincode', NULL, NULL, 'smp-sign', TRUE,
        'smp-client', FALSE, 'smp-1', 'this-just-a-sml-label', 'PUBLIC');

INSERT INTO `SMP_DOMAIN_MEMBER`
VALUES (1, '2026-02-02 08:22:56', '2026-02-02 08:22:56', 'ADMIN', 1, 1);

INSERT INTO `SMP_EXTENSION`
VALUES (1, '2026-02-02 08:15:55', '2026-02-02 08:15:55',
        'The extension implements Oasis SMP 1.0 and Oasis 2.0 document handlers', 'edelivery-oasis-smp-extension',
        'oasisSMPExtension', 'Oasis SMP 1.0 and 2.0', '1.0'),
       (2, '2026-02-02 08:15:55', '2026-02-02 08:15:55', 'The extension implements Oasis CPPA-CPP document handlers',
        'edelivery-oasis-cppa3-extension', 'oasisCPPA3Extension', 'Oasis CPPA 3.0', '1.0');

INSERT INTO `SMP_GROUP`
VALUES (1, '2026-02-02 08:24:16', '2026-02-02 08:24:16', NULL, 'groupb', 'PUBLIC', 1),
       (2, '2026-02-02 08:31:10', '2026-02-02 08:31:10', NULL, 'groupa', 'PUBLIC', 1);

INSERT INTO `SMP_GROUP_MEMBER`
VALUES (1, '2026-02-02 08:24:16', '2026-02-02 08:24:16', 'ADMIN', 1, 1),
       (2, '2026-02-02 08:31:10', '2026-02-02 08:31:10', 'ADMIN', 2, 1);

INSERT INTO `SMP_RESOURCE_DEF`
VALUES (1, '2026-02-02 08:15:55', '2026-02-02 08:15:55', 'Oasis SMP 1.0 Service group resource handler',
        'OasisSMPResource10Handler', 'edelivery-oasis-smp-1.0-servicegroup', 'text/xml', 'Oasis SMP 1.0 ServiceGroup',
        'smp-1', 1),
       (2, '2026-02-02 08:15:55', '2026-02-02 08:15:55', 'Oasis SMP 2.0 Service group resource handler',
        'OasisSMPResource20Handler', 'edelivery-oasis-smp-2.0-servicegroup', 'text/xml', 'Oasis SMP 2.0 ServiceGroup',
        'bdxr-smp-2', 1),
       (3, '2026-02-02 08:15:55', '2026-02-02 08:15:55', 'Oasis CPPA-CPP document', 'OasisCppa3CppHandler',
        'edelivery-oasis-cppa-3.0-cpp', 'text/xml', 'Oasis CPPA3 CPP document', 'cpp', 2);

INSERT INTO `SMP_DOMAIN_RESOURCE_DEF`
VALUES (1, '2026-02-02 08:22:49', '2026-02-02 08:22:49', 1, 1);

INSERT INTO `SMP_RESOURCE`
VALUES (1, '2026-02-02 08:24:49', '2026-02-02 08:24:49',
        'urn:oasis:names:tc:ebcore:partyid-type:unregistered:some-scheme', 'dd_participant_b', NULL, FALSE,
        'PUBLIC', 1, 1, 1),
       (2, '2026-02-02 08:34:05', '2026-02-02 08:34:05',
        'urn:oasis:names:tc:ebcore:partyid-type:unregistered:some-scheme', 'dd_participant_a', NULL, FALSE,
        'PUBLIC', 3, 1, 2);

INSERT INTO `SMP_RESOURCE_MEMBER`
VALUES (1, '2026-02-02 08:24:49', '2026-02-02 08:24:49', FALSE, 'ADMIN', 1, 1),
       (2, '2026-02-02 08:34:05', '2026-02-02 08:34:05', FALSE, 'ADMIN', 2, 1);

INSERT INTO `SMP_SUBRESOURCE_DEF`
VALUES (1, '2026-02-02 08:15:55', '2026-02-02 08:15:55', 'Oasis SMP 1.0 Service Metadata resource handler',
        'OasisSMPSubresource10Handler', 'edelivery-oasis-smp-1.0-servicemetadata', 'text/xml',
        'Oasis SMP 1.0 ServiceMetadata', 'services', 1),
       (2, '2026-02-02 08:15:55', '2026-02-02 08:15:55', 'Oasis SMP 2.0 Service Metadata resource handler',
        'OasisSMPSubresource20Handler', 'edelivery-oasis-smp-2.0-servicemetadata', 'text/xml',
        'Oasis SMP 2.0 ServiceMetadata', 'services', 2);

INSERT INTO `SMP_SUBRESOURCE`
VALUES (1, '2026-02-02 08:26:01', '2026-02-02 08:26:01', 'some-action-scheme', 'some-action-value', 2, 1, 1),
       (2, '2026-02-02 08:35:20', '2026-02-02 08:35:20', 'some-action-scheme', 'some-action-value', 4, 2, 1);
