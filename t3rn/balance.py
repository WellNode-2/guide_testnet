import os
import pandas as pd
from web3 import Web3
from datetime import datetime

# Ендпоінти для тестнет мереж
networks = {
    'Ethereum Sepolia': 'https://rpc.ankr.com/eth_sepolia',
    'Arbitrum Sepolia': 'https://sepolia-rollup.arbitrum.io/rpc',
    'Base Sepolia': 'https://sepolia.base.org',
    'Blast Sepolia': 'https://sepolia.blast.io',
    'OP Sepolia': 'https://sepolia.optimism.io',
    'brn': 'https://brn.rpc.caldera.xyz/http',
}

# Адреси для перевірки
addresses = [
]

def get_balance(w3, address):
    """Отримує баланс для вказаної адреси."""
    balance_wei = w3.eth.get_balance(address)
    return round(w3.from_wei(balance_wei, 'ether'), 8)

def main():
    try:
        # Підключаємо провайдери для обраних мереж
        providers = {network: Web3(Web3.HTTPProvider(endpoint)) for network, endpoint in networks.items()}
        
        data = {'Address': addresses}
        balance_sums = {address: 0 for address in addresses}  # Ініціалізуємо суми для вибраних адрес

        for network, w3 in providers.items():
            data[network] = []
            for address in addresses:
                balance = get_balance(w3, address)
                data[network].append(balance)
                
                # Додаємо баланс до суми для обраних мереж
                if network in ['Arbitrum Sepolia', 'Base Sepolia', 'Blast Sepolia', 'OP Sepolia']:
                    balance_sums[address] += balance

        # Формуємо таблицю
        df = pd.DataFrame(data)
        print(df.to_string(index=False))

        # Отримуємо поточну дату
        current_date = datetime.now().strftime("%Y-%m-%d %H:%M:%S")

        # Додаємо дату у таблицю та зберігаємо її у файл
        df['Date'] = current_date
        file_exists = os.path.isfile('balance.csv')
        df.to_csv('balance.csv', mode='a', index=False, header=not file_exists)

        # Виводимо суми для кожної адреси в обраних мережах
        for address, total_balance in balance_sums.items():
            print(f"{address}: {total_balance:.8f}")
        

    except Exception as e:
        print(f"Сталася помилка: {e}")

if __name__ == "__main__":
    main()
