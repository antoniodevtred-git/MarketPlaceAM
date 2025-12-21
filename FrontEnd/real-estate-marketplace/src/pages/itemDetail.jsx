import { useParams } from "react-router-dom";
import { items } from "../data/items";
import { useUsdToEth } from "../hooks/useUsdToEth";
import { startPurchase } from "../web3/escrowService";
import { parseEther } from "viem";

export default function ItemDetail() {
  const { id } = useParams();
  const item = items.find((i) => i.id === Number(id));

  const ethPrice = useUsdToEth(item?.usdPrice);

  if (!item) return <h2 className="text-center text-red-500 text-3xl mt-10">Item not found</h2>;

  async function handleBuy() {
    try {
      if (!ethPrice) {
        alert("ETH price not loaded. Try again.");
        return;
      }
  
      // Limitar decimales
      const safeEth = Number(ethPrice.toFixed(8));
      const ethRequired = parseEther(safeEth.toString());
  
      console.log("Trying purchase with:", safeEth, "ETH");
  
      const receipt = await startPurchase(item.id, ethRequired);
  
      console.log("TX completed:", receipt);
      alert("Purchase started successfully!");
    } catch (error) {
      console.error("Buy error:", error);
      alert(error.shortMessage || "Transaction failed");
    }
  }
  

  return (
    <div className="max-w-5xl mx-auto p-8">
      {/* IMAGE */}
      <img
        src={item.image}
        className="w-full h-[420px] object-cover rounded-xl shadow-lg"
      />

      {/* TITLE */}
      <h1 className="text-4xl font-bold mt-6">{item.title}</h1>

      {/* DESCRIPTION */}
      <p className="text-gray-700 text-lg mt-3">{item.description}</p>

      {/* PRICE + BUY BUTTON */}
      <div className="flex justify-between items-center mt-8">
        <div className="text-3xl font-semibold">
          ${item.usdPrice.toLocaleString()} USD  
          {ethPrice && (
            <span className="block text-gray-500 text-xl">
              ≈ {ethPrice.toFixed(4)} ETH
            </span>
          )}
        </div>

        <button
          onClick={handleBuy}
          className="bg-blue-600 text-white px-8 py-3 text-lg rounded-lg hover:bg-blue-700 transition"
        >
          Buy Now
        </button>
      </div>
    </div>
  );
}
