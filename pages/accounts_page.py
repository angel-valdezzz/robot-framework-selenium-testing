"""Localizadores declarativos, sin acciones ni dependencias externas."""


class AccountsPage:
    welcome = "css:#leftPanel p.smallText"
    heading = 'css:#showOverview h1.title'
    first_account = 'css:#accountTable tbody a'
    logout = 'link:Log Out'


ACCOUNTS_PAGE = AccountsPage()
