import { useEffect, useState } from "react";

export function useUsdToEth(usdAmount) {
  const [eth, setEth] = useState(null);

  useEffect(() => {
    async function fetchEth() {
      if (!usdAmount) return;

      try {
        const res = await fetch(
          "https://api.coingecko.com/api/v3/simple/price?ids=ethereum&vs_currencies=usd"
        );
        const data = await res.json();

        const ethUsd = data.ethereum.usd;
        const ethRequired = usdAmount / ethUsd;

        setEth(ethRequired);
      } catch (error) {
        console.error("Error fetching ETH price:", error);
      }
    }

    fetchEth();
  }, [usdAmount]);

  return eth;
}
