"""Repositorio de localizadores; no ejecuta acciones ni importa Selenium."""


class AccountsPage:
    def __init__(self):
        self.heading = 'css:#showOverview h1.title'
        self.first_account = 'css:#accountTable tbody a'
        self.logout = 'link:Log Out'


accounts_page = AccountsPage()


def get_variables():
    """Robot importa únicamente la instancia, no la clase."""
    return {"accounts_page": accounts_page}
