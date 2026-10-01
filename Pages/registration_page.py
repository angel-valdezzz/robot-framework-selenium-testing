"""Repositorio de localizadores; no ejecuta acciones ni importa Selenium."""


class RegistrationPage:
    def __init__(self):
        self.open_registration = 'link:Register'
        self.first_name = 'id:customer.firstName'
        self.last_name = 'id:customer.lastName'
        self.street = 'id:customer.address.street'
        self.city = 'id:customer.address.city'
        self.state = 'id:customer.address.state'
        self.zip_code = 'id:customer.address.zipCode'
        self.phone = 'id:customer.phoneNumber'
        self.ssn = 'id:customer.ssn'
        self.username = 'id:customer.username'
        self.password = 'id:customer.password'
        self.confirm_password = 'id:repeatedPassword'
        self.submit = 'css:#customerForm input[type="submit"]'
        self.confirmation = 'css:#rightPanel h1.title'
        self.message = 'css:#rightPanel p'


registration_page = RegistrationPage()


def get_variables():
    """Robot importa únicamente la instancia, no la clase."""
    return {"registration_page": registration_page}
