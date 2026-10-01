"""Repositorio de localizadores; no ejecuta acciones ni importa Selenium."""


class LoginPage:
    def __init__(self):
        self.username = 'css:form[name="login"] input[name="username"]'
        self.password = 'css:form[name="login"] input[name="password"]'
        self.submit = 'css:form[name="login"] input[type="submit"]'
        self.error = 'css:#rightPanel p.error'


login_page = LoginPage()


def get_variables():
    """Robot importa únicamente la instancia, no la clase."""
    return {"login_page": login_page}
