import { Link } from "react-router-dom";
import { useConnect, useAccount } from "wagmi";
import { injected } from "wagmi/connectors";

export default function Navbar() {
  const { connect } = useConnect();
  const { address, isConnected } = useAccount();

  return (
    <nav className="flex items-center justify-between px-8 py-4 bg-gray-900 text-white">
      <h1 className="text-2xl font-bold">
        <Link to="/">RealEstate Marketplace</Link>
      </h1>

      <div className="flex gap-6 text-lg">
        <Link to="/">Home</Link>
        <Link to="/category/real_estate">Properties</Link>
        <Link to="/category/vehicle">Vehicles</Link>
        <Link to="/category/luxury">Luxury</Link>
      </div>

      {/* BUTTON */}
      {isConnected ? (
        <span className="bg-gray-800 px-4 py-2 rounded-lg">
          {address.slice(0, 6)}...{address.slice(-4)}
        </span>
      ) : (
        <button
          onClick={() => connect({ connector: injected() })}
          className="bg-blue-600 px-4 py-2 rounded-lg hover:bg-blue-700 transition"
        >
          Connect Wallet
        </button>
      )}
    </nav>
  );
}
