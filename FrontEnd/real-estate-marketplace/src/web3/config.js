import { http, createConfig } from 'wagmi'
import { mainnet, arbitrum, sepolia } from 'wagmi/chains'
import { injected } from 'wagmi/connectors'

import { anvil } from 'wagmi/chains'

export const config = createConfig({
  chains: [anvil],
  transports: {
    [anvil.id]: http("http://127.0.0.1:8545"),
  },
})


/* export const config = createConfig({
  chains: [arbitrum, sepolia, mainnet],
  connectors: [
    injected({
      target: 'metaMask',
    }),
  ],
  transports: {
    [arbitrum.id]: http(),
    [sepolia.id]: http(),
    [mainnet.id]: http(),
  },
}) */
