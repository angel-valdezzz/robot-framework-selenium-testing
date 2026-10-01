"""Localizadores declarativos, sin acciones ni dependencias externas."""


class RegistrationPage:
    open_registration = 'link:Register'
    first_name = 'id:customer.firstName'
    last_name = 'id:customer.lastName'
    street = 'id:customer.address.street'
    city = 'id:customer.address.city'
    state = 'id:customer.address.state'
    zip_code = 'id:customer.address.zipCode'
    phone = 'id:customer.phoneNumber'
    ssn = 'id:customer.ssn'
    username = 'id:customer.username'
    password = 'id:customer.password'
    confirm_password = 'id:repeatedPassword'
    submit = 'css:#customerForm input[type="submit"]'
    confirmation = 'css:#rightPanel h1.title'
    message = 'css:#rightPanel p'


REGISTRATION_PAGE = RegistrationPage()
