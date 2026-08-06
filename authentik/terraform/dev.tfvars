authentik_url = "http://localhost:8000"
authentik_token = "rSRkkMvGLpe3mrfK6WF5tU7UGox9bt0fHpY8hgkHayj5l0MoKjMxyTs4dvqz"

aqualog_brand_domain = "localhost:8000"
aqualog_app_title = "MyAquariumLog"
aqualog_app_domain = "localhost:8000"
aqualog_auth_callback_url = "http://localhost:8002/auth/callback"
aqualog_app_url = "http://localhost:8002"

# terraform apply -var-file=dev.tfvars

# terraform import -var-file=dev.tfvars 'authentik_application.backend' 'aqualog'
# terraform import -var-file=dev.tfvars 'authentik_flow.aqualog-authentication-flow' 'aqualog-authentication-flow'
# terraform import -var-file=dev.tfvars 'authentik_flow.aqualog-enrollment-flow' 'aqualog-enrollment-flow'
# terraform import -var-file=dev.tfvars 'authentik_policy_expression.set_username_to_email' '1fdffe3e-1a76-4172-8743-16014c28def7'
# terraform import -var-file=dev.tfvars 'authentik_provider_oauth2.backend' 1
# terraform import -var-file=dev.tfvars 'authentik_stage_email.email_account_confirmation' 'e4e92bf8-56fc-405b-b2b8-7dea55087a78'
# terraform import -var-file=dev.tfvars 'authentik_stage_identification.authentication_identification' 'd4d8b63d-91ef-4133-8821-69873a1d387b'
# terraform import -var-file=dev.tfvars 'authentik_stage_prompt.custom_enrollment_prompt' 'ec4a9051-c9fb-4e71-965d-86099a59676c'
# terraform import -var-file=dev.tfvars 'authentik_stage_user_write.enrollment_user_write' 'd8cf8e9f-2a66-49c8-a5ea-513b873d7632'

# terraform import 'authentik_application.backend' 'aqualog'
# terraform import 'authentik_flow.aqualog-authentication-flow' 'aqualog-authentication-flow'
# terraform import 'authentik_flow.aqualog-enrollment-flow' 'aqualog-enrollment-flow'
# terraform import 'authentik_group.users' '4321da1f-0428-472c-8fbf-62525b724739'
# terraform import 'authentik_policy_binding.aqualog-access' '33607e61-0a27-4155-a5cc-a1e0c9710ad7'
# terraform import 'authentik_policy_expression.set_username_to_email' 'b6c0026f-46df-4ae7-9c53-be6a11feaa43'
# terraform import 'authentik_provider_oauth2.backend' 4
# terraform import 'authentik_stage_email.email_account_confirmation' '631b12ff-e631-479b-8df6-7f3749fe23ca'
# terraform import 'authentik_stage_identification.authentication_identification' 'fc924a2c-39df-444b-b8e3-9920bc77f8f5'
# terraform import 'authentik_stage_prompt.custom_enrollment_prompt' 1053df80-c025-4f3a-ac7f-9cb997af15ba
# terraform import 'authentik_stage_user_write.enrollment_user_write' a501b14e-98c6-45c8-a279-eab4adc0e380
