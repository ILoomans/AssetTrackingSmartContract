# MintOrigin Smart Contract

A smart contract to track and trace the origin of an asset while protecting the anonymity of the owners. The basic idea is that an NFT is sent as the asset is sold along, guaranteeing an immutable history of the assets past that cannot be tampered with. It allows the manufacturer of the asset to list distributors who then can perform checkups on the asset. This platform allows for the removal of information asymmetry in the resale process, by making it easy to identify both counterfeits and stolen assets. The contract is based on an ERC721 contract as all assets are Non-Fungible (unique). You can interact with this contract on (https://www.mintorigin.io/) and even download a mobile wallet (https://play.google.com/store/apps/details?id=com.modemo&hl=en_US&gl=US).


## Contract Overview (Note* ERC-1155 contract available as well)

### Owner Management (1 Parent Address 2 Child)
Having one address as the owner that can perform various actions can be deemed a vulnerability, as if an attacker gets the private keys of that address, they have power over the entire smart contract. Because of this, the contract uses a methodology of 2 child addresses that if they both agree can change the address of the contract owner. This action is facilitated through the changeParent function. On the first time function is called, one child account signs that they are proposing to change the owner with a given address. Then only if the other child's address agrees to change the owner's address with that same address will the owner's address be changed.

Likewise, the child address may be changed as well, the owner can propose the changing of a child address through the proposeChangeChild function. Notably, then, any child can vote to change the child address proposed by the owner, even the child address which will be replaced can call the function to replace itself. 

### Owner Actions 

The owner can set the manufacturers who can create tokens on their platform. They can also then remove a manufacturer from the platform or change the address of the manufacturer with the change manufacturer function.

### Manufacturer Actions (Token Minter)

The manufacturers are referred to in the contract as minters, as they have exclusive access to mint tokens representing their assets. 

Including this, they can integrate on the smart contract who their distributors are. The smart contract assumes that certain manufacturers could share distributors. Therefore they have the option to create a distributor if the distributor does not already exist on our platform with the createDist function, or use the addDist if the distributor does already exist. Following this, they can remove the distributor from their list of distributors, but not from others list of distributors. 

Also, manufacturers can create tokens, sending it immediately to themselves or to another address. This is achieved in the onlyManufacturer function.

Furthermore there a function in place (viewDist and viewDists) to view a manufacturers listed distributors.

### Distributor Actions 

Distributors are another identifiable actor on the smart contract. They have the unique ability however to perform checkups on assets that originate from a manufacturer for which they are a registered distributor. This function then signals an event confirming on the blockchain that at that point in time the asset was in good shape. 


### Regular Wallet Holder

The regular wallet holder holds no special permissions, so everything the regular wallet holder can do, the distributors and manufacturers can also do, with that, there are still strong benefits for them to use the platform. 
#### Trace the origin of an asset
With the ERC 721 contract, there are by default events triggered on the blockchain every time an asset is transferred. Therefore the history of transfers of the asset and of the asset can be tracked on the smart contract. 

![alt text](https://play-lh.googleusercontent.com/cypeaYYbLkkH7Vq7NynsQ9C9wVyzb-RAR6K93ezuBoFrASGvHuqh_UoZMvsgNd4qEt4=w1440-h620)
#### Identify stolen 

A stolen asset could quickly be identified, as the thief of the asset would not have the token representing the asset. Furthermore, the asset could be marked as stolen on the smart contract, identifying to anyone evaluating the asset that it is stolen.
#### Identify counterfeits

Only manufacturers representing the given asset will have the ability to integrate tokens representing the asset that they created. Therefore if a counterfeiter tries to imitate an asset, they will not have the token to represent the asset, making sure that the buyer will know that the asset is either counterfeit or stolen. 
#### Eliminate Information Asymmetry in the resale of the asset

Information asymmetry is eliminated through the use of this decentralized platform. The quick identification of counterfeit or stolen bikes together with the immutable ledger of an asset's history and the recording of its checkups on an immutable decentralized ledger provides an unseen degree of trust when reselling the asset.


#### Handling transaction fees

In order to commit a transaction on the blockchain, a small transaction fee must be paid to incentive miners. It is unrealistic to assume that all wallet holders will purchase ether to transfer it, therefore a small amount of ether should be sent along. This is done through the payable function sendValueToken which sends a small amount of ether every time the token is transferred from one address to another. 


## Requirements
1. Node 
2. npm 

## Step to run

1. npm i 
2. npm i -g ganache-cli
3. ganache-cli
4. open new terminal
5. npm run test