import { Link } from "react-router-dom";
import { useEthPrice } from "../hooks/useEthPrice";

export default function ItemCard({ item, onBuy }) {
  const ethPrice = useEthPrice();

  const ethAmount = ethPrice ? (item.priceUSD / ethPrice).toFixed(4) : "...";

  return (
    <div className="bg-white rounded-xl shadow-lg hover:shadow-2xl transition overflow-hidden">
      <Link to={`/item/${item.id}`}>
        <img
          src={item.image}
          alt={item.title}
          className="w-full h-56 object-cover hover:scale-105 transition-transform"
        />
      </Link>

      <div className="p-5">
        <Link to={`/item/${item.id}`}>
          <h2 className="text-xl font-bold text-gray-800 hover:text-blue-600 transition">
            {item.title}
          </h2>
        </Link>

        <p className="text-gray-600 text-sm mt-2 line-clamp-2">
          {item.description}
        </p>

        <div className="flex items-center gap-3 mt-4">
          <span className="text-2xl font-bold text-blue-600">
            {ethAmount} ETH
          </span>

          <span className="text-gray-500 text-lg">
            ≈ ${item.priceUSD ? item.priceUSD.toLocaleString() : "..."} USD
          </span>
        </div>

        <button
          onClick={() => onBuy(item)}
          className="bg-blue-600 text-white px-4 py-2 rounded-md hover:bg-blue-700 transition mt-4"
        >
          Buy
        </button>
      </div>
    </div>
  );
}
