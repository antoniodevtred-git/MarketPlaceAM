import { http, createConfig } from 'wagmi'
import { mainnet, arbitrum, sepolia } from 'wagmi/chains'
import { injected } from 'wagmi/connectors'

export const config = createConfig({
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
})
