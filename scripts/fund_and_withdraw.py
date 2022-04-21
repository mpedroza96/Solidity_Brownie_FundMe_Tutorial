from eth_account import Account
from brownie import Fundme
from scripts.helpful_scripts import get_account


def fund():
    fund_me = Fundme[-1]
    account = get_account()
    entrance_fee = fund_me.getEntranceFee()
    print(entrance_fee)
    print(f"The entrance fee is: {entrance_fee}")
    fund_me.fund({"from": account, "value": entrance_fee})


def withdraw():
    fund_me = Fundme[-1]
    account = get_account()
    fund_me.withdraw({"from": account})


def main():
    fund()
    withdraw()
