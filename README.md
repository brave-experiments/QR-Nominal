# QR-Nominal
An iOS application to Decrypt and display message from multi-sequence [QR codes](https://en.wikipedia.org/wiki/QR_code) (MQRs).

At present,
sequences for the [Cobo Vault](https://cobo.com/hardware-wallet) are supported.
Take a look at Xinxi Wang's overview of the MQRs on
[Coinut](https://coinut.com/blog/a-brief-review-of-cobo-vault-the-most-secure-hardware-wallet/).
Here are three similar examples from this application:

The mobile app asks the Cobo Vault to sign a transaction:

    {
     "hotVersion" : 10502,
     "data" : {
       "coinId" : "ethereum",
       "signId" : "302407223f37f008fd1726fa107bc91f",
       "hdPath" : "M\/44'\/60'\/0'\/0\/0",
       "time" : 1562936615378,
       "data" : {
         "chainId" : 1,
         "memo" : "",
         "gasLimit" : "0x5910",
         "value" : "0xde0b6b3a7640000",
         "to" : "0x1a69e3C1Deeb9D882b82E49b530739d3F7824145",
         "gasPrice" : "0xb2d05e00",
         "nonce" : 4
       },
       "displayTime" : "2019\/07\/12 08:03:35 -05:00",
       "type" : "sign",
       "hdToken" : "01c7e430964a31f059cf2e03275954f53b396ffeab50731a8e4d5552db329e3bdd8452db0a4fa4b5e64ba13479b895282ba57c7b3b3ef385add8f9c06e72c2496f881ba3dbfa4afb1b14be1c108f33d0"
     },
     "description" : "cobovault qrcode protocol",
     "version" : 1
    }

The Cobo Vault responds with a signed transaction:

    {
     "coldVersion" : 10101,
     "data" : {
       "type" : "signed",
       "signId" : "302407223f37f008fd1726fa107bc91f",
       "data" : {
         "rawTx" : "0xf86b0484b2d05e00825910941a69e3c1deeb9d882b82e49b530739d3f7824145880de0b6b3a76400008026a0593028c1981717a0128373c972415516f691e5bbddf626bc505d2c385607d2e8a068b31b08b1639de536547caba1b6e12c08598bf2be2cb82edde9711b29b0ad4d",
         "txId" : "0xfde7570089b78fa553bc2225a41fbfff86f6884e278f46d0786904eb00348489"
       }
     },
     "description" : "cobo valut qrcode protocol",
     "version" : 1
    }

The challenge send by when tapping `Web Authentication` to
[verify](https://cobo.com/hardware-wallet/authentication) on the Cobo Vault:

    {
     "version" : 1,
     "data" : {
       "type" : "webAuth",
       "data" : "BJSeKjr4o+KJTfmSjsp4UYzhI36TlaM\/KZaPrkV0cd3l\/h+kxQ9XUwSsmFEftWQe5M2k0ExI7NXVO\/hmcp8TSTgaD4MYGqjn55LOa0YydtAjtCCczUBQu75UynFhqZ9OnK2nDYwJLv1OkOLJ2gfwGahA5oenxkNhdMgBzKdUypE+XrwgJY02kxW9QDquuf+xVZAAQ4DdIYjjm8h9hyhHt67aUJasmd0RMw=="
     },
     "description" : "cobovalut qrcode protocol"
    }

# Compilation
We encourage you to build your own version of the application: _cognoscere nisi habeat fiduciam_.

## Prior to compilation

        brew install carthage
        
 In project directory:
 
        carthage update --platform ios
