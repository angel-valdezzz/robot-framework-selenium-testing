"""Locators verified against ParaBank's openaccount, transfer and activity JSPs."""

class BankingPage:
    open_account = "link:Open New Account"
    account_type = "id:type"
    funding_account = "id:fromAccountId"
    open_submit = "css:#openAccountForm input.button"
    new_account = "id:newAccountId"
    transfer = "link:Transfer Funds"
    amount = "id:amount"
    transfer_from = "id:fromAccountId"
    transfer_to = "id:toAccountId"
    transfer_submit = "css:#transferForm input.button"
    transfer_result = "css:#showResult h1"
    result_from = "id:fromAccountIdResult"
    result_to = "id:toAccountIdResult"
    result_amount = "id:amountResult"
    account_id = "id:accountId"
    balance = "id:balance"
    transactions = "css:#transactionTable tbody"

BANKING_PAGE = BankingPage()
