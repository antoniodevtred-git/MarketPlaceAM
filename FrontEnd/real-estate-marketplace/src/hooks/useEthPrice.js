import { useEffect, useState } from "react";

export function useEthPrice() {
  const [price, setPrice] = useState(null);

  useEffect(() => {
    async function fetchPrice() {
      try {
        const res = await fetch(
          "https://api.coingecko.com/api/v3/simple/price?ids=ethereum&vs_currencies=usd"
        );
        const data = await res.json();
        setPrice(data.ethereum.usd);
      } catch (err) {
        console.error("Failed to fetch ETH price", err);
      }
    }

    fetchPrice();
    const interval = setInterval(fetchPrice, 60000); // update every 1 min

    return () => clearInterval(interval);
  }, []);

  return price;
}
