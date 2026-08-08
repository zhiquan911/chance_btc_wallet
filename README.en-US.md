

# ⚠️Please read the following content completely before using

# 👛Chance Bitcoin Wallet

This is a Bitcoin wallet application for iOS. It is not a full-node wallet; rather, it is a lightweight wallet designed for mobile devices. It focuses solely on securely storing the user's important private key information and supports features such as creating Bitcoin accounts, sending and receiving Bitcoin, querying wallet sub-accounts, backing up the wallet, and restoring the wallet. It does not store complete blockchain data, validate P2P network-broadcasted transactions, or mine.

> Technical Support:<br>
> 🐧QQ Group: 624834691  <br>
> 📮Email: zhiquan911@qq.com

**BTC Donations/Support**:  3G4NdQQyCJK1RS5URb4h5KogWEyR4Mk16A

## 🤖Public Version

![intro.jpg](https://github.com/zhiquan911/chance_btc_wallet/blob/master/introduction/intro.jpg)

## ✨Application Features

- **Swift Open Source** – An iOS wallet app written in Swift 3.0, supporting iOS 9+.
- **HD Model** – An account system based on the "Hierarchical Deterministic (HD) standard model". Users can create up to approximately 2.1 billion sub-account addresses using a single wallet generated with a "recovery phrase and password".
- **Multi-Signature** – In addition to regular accounts, we provide the ability to create multi-signature accounts by combining multiple wallets. This significantly enhances the security of user assets. The multi-signature transaction protocol allows for the convenient completion of signing steps across multiple accounts.
- **Remote Node Service** – Supports connecting to various trusted node services (e.g., blockchain.info, insight.bitpay.com, etc.). Transactions can be signed offline and broadcasted online without the need to sync the blockchain, thereby saving more device storage space.
- **Phrase Backup** – Supports backing up and restoring the wallet using a "recovery phrase and password", and also allows backing up individual sub-account private keys separately.
- **Keychain Encryption** – Utilizes Apple's recommended low-level security framework, Keychain. Important data such as private keys are saved exclusively on the device via Keychain. Private key data never leaves the device or enters the network.
- **Touch ID** – Supports Touch ID fingerprint password verification.
- **iCloud Backup** – The wallet's "account system data" can be enabled for automatic iCloud synchronization. Restoring the wallet with a "recovery phrase and password" will automatically sync the corresponding "account system data", allowing you to recover lost HD and multi-signature accounts. This ensures the security of private keys while providing users with a convenient way to migrate data to new devices.

## 💾Data Structure

This application divides data into three parts: "Recovery Phrase and Password", "Account System", and "Transaction Data".

- Recovery Phrase and Password: The app uses Apple's Keychain framework to securely store encrypted wallet private keys on the device. Private keys are not included in iCloud's automatic backup. Therefore, users must remember their wallet's "recovery phrase and password". If the device is damaged, the wallet can be restored on a new device by importing the phrase and password, ensuring assets are not lost.
- Account System: This data is also crucial. Although you can restore an HD wallet using the "recovery phrase and password", there is no strict standard for HD account systems; different wallets use different structures. You must use the same HD wallet application to restore the data. In this wallet, the account system is stored separately from the root private key information. The account system is saved using a Realm database, containing HD account tree depth levels, index positions, and multi-signature account redeem scripts. The database file is named using the SHA256 hash of the private key seed, allowing the app to maintain multiple account system datasets, which are then automatically synchronized via iCloud for convenient future wallet data recovery.
- Transaction Data: To conserve device resources, the app does not sync complete blockchain data via P2P networks. Instead, it connects to trusted cloud nodes to fetch account-related data and broadcast transactions via those nodes. Synced data is saved to a local transaction database and is not automatically synchronized via iCloud, as iCloud storage is limited and expansion requires paying Apple's annual fee.

## 🔐Security Scheme

- Private key information, such as the "recovery phrase and password", is stored on the current device using Apple's Keychain framework. It will be lost if you switch to a new device or if the current device is damaged. If you fully trust Apple, you can use this app with peace of mind. The app allows viewing the "recovery phrase", but the "password" cannot be viewed. Remember the password! Even if the "recovery phrase" is leaked, the original wallet cannot be restored without it.
- When generating a transaction, the private key signature type used is "SIGHASH_ALL". This is the default type and is used by the vast majority of transactions today. As the name implies, it signs the entire transaction. First, all outputs and inputs are organized. Similar to the Hex decomposition process mentioned above, each input corresponds to a signature slot, which is temporarily left empty. Other fields, including `sequence`, must be filled out, forming a complete transaction Hex (missing only the signature fields). Then, each input must be signed using its corresponding private key. Once signed, they are filled into their respective positions: N inputs yield N signatures. Simply put, this means: for this transaction, I approve and only approve these inputs and outputs, and I agree to spend my specific input.
- To conserve device resources, the app does not sync complete blockchain data via P2P networks. It only connects to trusted cloud nodes to fetch account-related data and broadcast transactions via those nodes. If you understand Bitcoin transaction broadcasting, you know it does not require providing the private key itself, only the signature of the private key over the "unspent transaction outputs" (UTXOs). Since the signature type is "SIGHASH_ALL", cloud nodes cannot tamper with the transaction's output section before broadcasting it. In summary, using feature-rich, trusted cloud nodes significantly reduces device storage requirements, simplifies the process of connecting to the Bitcoin network, and securely protects the most critical private keys.
- Regular HD accounts only require their respective account private keys to access their assets. If a specific account's private key is compromised, only the assets of that account will be stolen, without affecting other accounts. The app only provides viewing options for sub-accounts' "private keys" and "public keys". It does not provide viewing options for the root account's keys.
- Multi-signature accounts are created by combining public keys from multiple regular accounts and are referred to as a "redeem script". Transaction validation requires multiple regular accounts to jointly sign the transaction (reaching the required threshold number of signatures) for it to take effect. This is the highest security level account type in Bitcoin, but it is more complex to use.

## 👨‍👩‍👧‍👦Multi-Signature Transaction Protocol
After creating a multi-signature account by sharing public keys, the account does not collect the private keys of other public key providers. Instead, it generates a "redeem script" from these public keys and stores it in the account database. The assets received at the address of this "redeem script" belong to everyone. When the account needs to spend assets and initiate a transaction, the required number of signatures must be provided by the participants to be verified and confirmed by the Bitcoin network.

> During the joint signing step, please note the following:

> - It is impossible to provide all private keys to the transaction initiator for signing, as this would defeat the purpose of creating a multi-signature account.
> - Bitcoin's script system is stack-based. Therefore, when verifying signatures, the order of signatures must match the order of keys in the redeem script for the script to verify correctly.
> - The number of unspent transaction records (UTXOs) used to spend from the account may be multiple, and each record requires a signature.
> - Only the account maintainer might hold the redeem script. Others do not need to keep it long-term; when a transaction is initiated, they simply need to provide a signature.

To address these issues, I have defined a multi-signature transaction protocol. The initiating transaction creator generates a pending signature transaction data payload and sends it to other signatories via the network (regardless of signing order). The recipient signs it, verifies if the collected signatures are sufficient, and if valid, broadcasts it to the Bitcoin network. If not, the signature information is merged into the pending transaction data and forwarded to other signatories (regardless of order), and so on, until the final person who has collected all signatures broadcasts the transaction to the network. The data text for this protocol uses "multisig:" as the protocol identifier prefix.

> Text Format: multisig:{"rawTx":"01000000021138...","redeemScriptHex":"532103324c4"...,"keySignatures":{"0":["3045022100...","304402..."],"2":["30450221...","3044022059bd..."]}}

The content following "multisig:" is actually a JSON structure:
```swift
{
    //rawTx，空白签名交易单的hex
    "rawTx": "01000000021138c1e2f7735a8589fa2a3df2426fbaf24a047330c5a0dc14ffadf7dd8767b10000000000ffffffff6d3c772c389561f20b4afec072cbb61cbe15b42aa37fb50e98ad78f3021241790000000000ffffffff02409c0000000000001976a914d1f9af334c34de5558c0d6785d2f22e25a9eff6d88ac80131c000000000017a914dde71db06038ed3a3bead881b20176dd6de8ec068700000000",

    //redeemScriptHex，多重签名赎回脚本的hex
    "redeemScriptHex": "532103324c40d0042fb1c21be5d0688e1e0c7090e16d0fc6abbb0563ba368bc2d7f20b2102c6287fd02ec3f5c3689d9152688553670d9f84fdc124c621e2ffe7be8ccc60bc21028c42e572d465753610915266f5f7855ebcb74b7f7db434a2732685cb290c20a953ae",

    //keySignatures，各私钥提供的交易签名hex
    "keySignatures": {
        //第1条钥匙所在赎回脚本的位置
        "0": [
            //对第1条未花交易输入的签名
            "3045022100ddccdb3a60054cb3fd8973ecf24ca0f09f27533a42a7d1b8f30768b03350513002201b034827ad6a3a23850d485bf09f4b6c1e4a15d081f22a376992e61aa37ca81501",
            //对第2条未花交易输入的签名
            "304402205f11cf0824a435f6445b20f941d74d4f1e879bd5b3b6c2cb72e58e5e335796b9022042cb6d3b28c70316e71b6ae6b4ca4103cb25bc3f57dab7f5fe9a5534f2d5e30f01"
        ],
        //第2条钥匙的交易签名信息
        "2": [
            "30450221008dd0d34169ecc73022f3ab7adb190068e8a85c09f5b578c73746d7118aaf3e3e02200830884592a60313a1432c494af62fe658361c23919401d59d6c850feac5216f01",
            "3044022059bdd1ff6a07bc3bcd4fc58f8a171ee2a77d7ac22c9f69a812d665032da48259022076fe2dcd69b2e0bf05e87c09a419e3f1202529f8a39858ae0170a84be34276e201"
        ]
    }
}

```

> Protocol Parsing:

> - `rawTx`: The transaction hex without signatures, used by signatories to view transaction details (e.g., how much Bitcoin is being sent to which address).
> - `redeemScriptHex`: Each signatory might be the last one to complete the verification. It is needed for broadcasting the transaction, as the transaction script must contain the redeem script information. The redeem script contains public key hashes, which are used to determine the signing order/position of the signatories.
> - `keySignatures`: The transaction signature data structure. This structure uses the signature sequence number as the key, corresponding to the multiple transaction input signatures provided by the signatory.

Finally, the tasks of parsing and encapsulating the protocol are handled by the wallet program, implemented in the `MultiSigTransaction` class. Note that this protocol is not part of a Bitcoin Improvement Proposal (BIP); it is tailored specifically for this wallet application.

## 🛠Testnet Debugging

In Settings - Blockchain Node, select the testnet online node.

![测试网](https://github.com/zhiquan911/chance_btc_wallet/blob/master/introduction/testnet.jpg)

You can obtain some Bitcoin testnet coins from this website:
https://testnet.manu.backend.hamburg/faucet


## 📦Product Features

![产品功能](https://github.com/zhiquan911/chance_btc_wallet/blob/master/introduction/Chance%20Wallet.png)

## 🚀Development Plan

- Develop a Swift version of Bitcoin Core (an independent project). Currently, the Objective-C based coreBitcoin open-source library is used. This library is excellently designed, implements many great BIPs, and has stable, user-friendly code. The issue is that the author rarely updates it anymore. Facing potential future "SegWit" upgrades, we will need to modify it ourselves. Having developed Swift projects for years and loving the Swift language, I decided to develop a Swift version of Bitcoin Core. This approach offers many benefits:

    >  - Due to Swift's open-source nature, the new library can support iOS/macOS/Linux, and possibly even Windows.
    >  - Support for "SegWit" upgrades, which will facilitate the development of more extended features in the future.

- Develop support for subscribing to global Bitcoin market prices.
- Develop an open wallet service platform for sending/receiving in-app messages, sending/receiving Bitcoin, creating multi-signature accounts, and managing multi-signature transactions.

## 👾Risk Warning

- This app is limited to Apple devices, and the most critical private key information is stored in the Keychain. It is unknown whether Apple has left any backdoors.
- Once the wallet's "recovery phrase and password" are lost and not backed up, they can never be recovered, resulting in the loss of all account assets.
- Multi-signature accounts require securely storing the private keys of multiple accounts. If keys are lost such that they fall below the required threshold number, the assets of the multi-signature account can never be accessed. The "redeem script" is also crucial; if lost, it must be regenerated. The app's "Account System" already contains and saves the redeem script for multi-signature accounts. For added security, the app also provides an option to export the redeem script for users to back up independently.
- If the trusted cloud node goes offline, Bitcoin assets will not be lost, but the wallet will be unable to display account balances or broadcast Bitcoin transactions. At this point, you must wait for the developer to upgrade the software and switch to a new cloud node to continue usage. Alternatively, you can export the sub-account's private key and import it into another client that supports private key imports to restore and continue using the wallet.

## 🌏Donation Plan

To encourage developers to share technology and open-source code more actively, we have launched a cryptocurrency donation plan. Donations are accepted in the following currency:

- **BTC Address**:  3G4NdQQyCJK1RS5URb4h5KogWEyR4Mk16A
