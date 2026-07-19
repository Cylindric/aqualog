#!/usr/bin/env python3

from __future__ import annotations

import json
import mimetypes
import os
from pprint import pprint
import sys
from pathlib import Path
from typing import Any
from urllib import error, request, parse
    

AUTH_TOKEN = os.environ.get("AUTHENTIK_TOKEN")
API = os.environ.get("AUTHENTIK_API", "https://auth.aqualog.cylindric.net/api/v3")
ASSETS_DIR = Path(__file__).resolve().parent.parent / "assets"



def api_headers(*, content_type: str | None = None) -> dict[str, str]:
    headers = {
        "accept": "application/json",
        "authorization": f"Bearer {AUTH_TOKEN}",
    }
    if content_type is not None:
        headers["content-type"] = content_type
    return headers


def send_request(req: request.Request) -> str:
    try:
        with request.urlopen(req) as response:
            return response.read().decode("utf-8")
    except error.HTTPError as exc:
        body = exc.read().decode("utf-8", errors="replace")
        raise SystemExit(f"Request failed: {exc.code} {exc.reason}\n{body}") from exc
    except error.URLError as exc:
        raise SystemExit(f"Request failed: {exc.reason}") from exc


def encode_file_upload_formdata(source_file: Path, destination_path: str) -> tuple[bytes, str]:
    boundary = "----AquaLogAuthentikBoundary"
    content_type = mimetypes.guess_type(source_file.name)[0] or "application/octet-stream"
    file_bytes = source_file.read_bytes()

    parts = [
        f"--{boundary}\r\n".encode("utf-8"),
        b'Content-Disposition: form-data; name="name"\r\n\r\n',
        destination_path.encode("utf-8"),
        b"\r\n",
        f"--{boundary}\r\n".encode("utf-8"),
        (
            f'Content-Disposition: form-data; name="file"; '
            f'filename="{source_file.name}"\r\n'
        ).encode("utf-8"),
        f"Content-Type: {content_type}\r\n\r\n".encode("utf-8"),
        file_bytes,
        b"\r\n",
        f"--{boundary}--\r\n".encode("utf-8"),
    ]
    return b"".join(parts), f"multipart/form-data; boundary={boundary}"


def list_files() -> str:
    req = request.Request(f"{API}/admin/file/", headers=api_headers(), method="GET")
    return send_request(req)


def upload_file(source_file: str, destination_path: str) -> None:
    file_path = ASSETS_DIR / source_file
    print(f"Uploading file: {source_file} in {ASSETS_DIR} = {file_path}...")

    if not file_path.exists():
        raise SystemExit(f"Missing asset: {file_path}")
    

    payload, content_type = encode_file_upload_formdata(file_path, destination_path)
    req = request.Request(
        f"{API}/admin/file/",
        data=payload,
        headers=api_headers(content_type=content_type),
        method="POST",
    )
    print(send_request(req))


def get_flow(name: str) -> dict[str, Any]:
    url_encoded_name = parse.quote_plus(name)
    uri = f"{API}/flows/instances/?slug={url_encoded_name}"
    req = request.Request(uri, headers=api_headers(), method="GET")
    response =  json.loads(send_request(req))
    count = response["pagination"]["count"]
    flows = response["results"] if count > 0 else None
    if not flows:
        raise SystemExit(f"Flow '{name}' not found.")
    return flows[0]


def get_property_mapping(name: str) -> dict:
    url_encoded_name = parse.quote_plus(name)
    uri = f"{API}/propertymappings/all/?name={url_encoded_name}"
    req = request.Request(uri, headers=api_headers(), method="GET")
    response =  json.loads(send_request(req))
    count = response["pagination"]["count"]
    results = response["results"] if count > 0 else None
    if not results:
        raise SystemExit(f"Property mapping '{name}' not found.")
    return results[0]


def get_certificate(name: str) -> dict:
    url_encoded_name = parse.quote_plus(name)
    uri = f"{API}/crypto/certificatekeypairs/?name={url_encoded_name}"
    req = request.Request(uri, headers=api_headers(), method="GET")
    response =  json.loads(send_request(req))
    count = response["pagination"]["count"]
    results = response["results"] if count > 0 else None
    if not results:
        raise SystemExit(f"Certificate '{name}' not found.")
    return results[0]


def get_provider(name: str) -> dict | None:
    url_encoded_name = parse.quote_plus(name)
    uri = f"{API}/providers/oauth2/?search={url_encoded_name}"
    req = request.Request(uri, headers=api_headers(), method="GET")
    response =  json.loads(send_request(req))
    count = response["pagination"]["count"]
    results = response["results"] if count > 0 else None
    if not results:
        return None
    return results[0]


def create_provider() -> dict:
    default_provider_authorization_flow = get_flow("default-provider-authorization-implicit-consent")
    default_provider_invalidation_flow = get_flow("default-provider-invalidation-flow")
    
    openid_mapping = get_property_mapping("authentik default OAuth Mapping: OpenID 'openid'")
    email_mapping = get_property_mapping("authentik default OAuth Mapping: OpenID 'email'")
    profile_mapping = get_property_mapping("authentik default OAuth Mapping: OpenID 'profile'")
    offline_access_mapping = get_property_mapping("authentik default OAuth Mapping: OpenID 'offline_access'")

    signing_key = get_certificate("authentik Self-signed Certificate")
    payload = {
        "name": "aqualog",
        "authentication_flow": None,
        "authorization_flow": default_provider_authorization_flow["pk"],
        "invalidation_flow": default_provider_invalidation_flow["pk"],
        "property_mappings": [
            openid_mapping["pk"],
            email_mapping["pk"],
            profile_mapping["pk"],
            offline_access_mapping["pk"]
        ],
        "component": "ak-provider-oauth2-form",
        "assigned_application_slug": None,
        "assigned_application_name": None,
        "assigned_backchannel_application_slug": None,
        "assigned_backchannel_application_name": None,
        "verbose_name": "OAuth2/OpenID Provider",
        "verbose_name_plural": "OAuth2/OpenID Providers",
        "meta_model_name": "authentik_providers_oauth2.oauth2provider",
        "client_type": "public",
        "grant_types": [
            "authorization_code",
            "refresh_token"
        ],
        "access_code_validity": "minutes=1",
        "access_token_validity": "minutes=5",
        "refresh_token_validity": "days=30",
        "refresh_token_threshold": "hours=1",
        "include_claims_in_id_token": True,
        "signing_key": signing_key["pk"],
        "encryption_key": None,
        "redirect_uris": [
            {
                "matching_mode": "strict",
                "url": "https://www.aqualog.cylindric.net/auth/callback",
                "redirect_uri_type": "authorization"
            }
        ],
        "logout_uri": "",
        "logout_method": "backchannel",
        "sub_mode": "hashed_user_id",
        "issuer_mode": "per_provider",
        "jwt_federation_sources": [],
        "jwt_federation_providers": []
    }
    payload_json = json.dumps(payload).encode("utf-8")
    req = request.Request(
        f"{API}/providers/oauth2/",
        data=payload_json,
        headers=api_headers(content_type="application/json"),
        method="POST",
    )
    result = send_request(req)
    print("Provider created.")
    return json.loads(result)


def get_application(name:str) -> dict | None:
    url_encoded_name = parse.quote_plus(name)
    uri = f"{API}/core/applications/?slug={url_encoded_name}"
    req = request.Request(uri, headers=api_headers(), method="GET")
    response =  json.loads(send_request(req))
    count = response["pagination"]["count"]
    results = response["results"] if count > 0 else None
    if not results:
        return None
    return results[0]


def create_application() -> None:
    provider = get_provider("aqualog")
    if not provider:
        raise SystemExit("Provider 'aqualog' not found. Cannot create application.")
    
    print(f"Adding Application to Provider: {provider['name']} (ID: {provider['pk']})...")
    payload = {
      "name": "AquaLog",
      "slug": "aqualog",
      "provider": provider["pk"],
      "backchannel_providers": [],
      "launch_url": "https://www.aqualog.cylindric.net",
      "open_in_new_tab": False,
      "meta_launch_url": "https://www.aqualog.cylindric.net",
      "meta_icon": "aqualog/favicon.png",
      "meta_description": "",
      "meta_publisher": "AquaLog",
      "policy_engine_mode": "any",
      "group": "AquaLog",
      "meta_hide": False
    }
    payload_json = json.dumps(payload).encode("utf-8")
    req = request.Request(
        f"{API}/core/applications/",
        data=payload_json,
        headers=api_headers(content_type="application/json"),
        method="POST",
    )
    result = send_request(req)


def get_brand(name:str) -> dict | None:
    url_encoded_name = parse.quote_plus(name)
    uri = f"{API}/core/brands/?domain={url_encoded_name}"
    req = request.Request(uri, headers=api_headers(), method="GET")
    response =  json.loads(send_request(req))
    count = response["pagination"]["count"]
    results = response["results"] if count > 0 else None
    if not results:
        return None
    return results[0]


def create_brand() -> None:
    application = get_application("aqualog")
    if not application:
        raise SystemExit("Application 'aqualog' not found. Cannot create brand.")

    print(f"Adding Brand to application {application['name']} (ID: {application['pk']})...")
    payload = {
      "domain": "auth.aqualog.cylindric.net",
      "default": False,
      "branding_title": "authentik",
      "branding_logo": "aqualog/logo-login.png",
      "branding_favicon": "aqualog/favicon.png",
      "branding_custom_css": "",
      "branding_default_flow_background": "aqualog/background1.png",
      "flow_authentication": None,
      "flow_invalidation": None,
      "flow_recovery": None,
      "flow_unenrollment": None,
      "flow_user_settings": None,
      "flow_device_code": None,
      "flow_lockdown": None,
      "default_application": application["pk"],
      "web_certificate": None,
      "client_certificates": [],
      "attributes": {}
    }
    payload_json = json.dumps(payload).encode("utf-8")
    req = request.Request(
        f"{API}/core/brands/",
        data=payload_json,
        headers=api_headers(content_type="application/json"),
        method="POST",
    )
    result = send_request(req)


def main() -> int:

    ###############################################################################################
    # UPLOAD ASSETS
    ###############################################################################################
    current_files = list_files()
    files = json.loads(current_files)
    for asset_name in [
        "favicon.png",
        "background1.png",
        "logo-banner.png",
        "logo-login.png",
    ]:
        filename = f"aqualog/{asset_name}"
        if filename not in [file['name'] for file in files]:
            print(f"Uploading asset: {asset_name}...")
            upload_file(asset_name, destination_path=filename)
        else:
            print(f"Asset '{asset_name}' already exists. Skipping upload.")

    ###############################################################################################
    # CREATE THE PROVIDER
    ###############################################################################################
    provider = get_provider("aqualog")
    if provider:
        print("Provider 'aqualog' already exists. Skipping creation.")
    else:
        print("Creating provider 'aqualog'...")
        provider = create_provider()
    
    ###############################################################################################
    # CREATE THE APPLICATION
    ###############################################################################################
    application = get_application("aqualog")
    if application:
        print("Application 'aqualog' already exists. Skipping creation.")
    else:
        print("Creating application 'aqualog'...")
        application = create_application()

    ###############################################################################################
    # CREATE THE BRAND
    ###############################################################################################
    brand = get_brand("auth.aqualog.cylindric.net")
    if brand:
        print("Brand 'auth.aqualog.cylindric.net' already exists. Skipping creation.")
    else:
        print("Creating brand 'auth.aqualog.cylindric.net'...")
        brand = create_brand()

    ###############################################################################################
    # END
    ###############################################################################################
    # print(f"Provider Client ID: {provider}")
    print(f"\nProvider Client ID: {provider['client_id']}")
    return 0

if __name__ == "__main__":
    sys.exit(main())