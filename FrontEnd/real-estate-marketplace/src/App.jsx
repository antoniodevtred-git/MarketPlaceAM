import { Routes, Route } from "react-router-dom";
import Navbar from "./components/Navbar";
import ItemCard from "./components/ItemCard";
import ItemDetail from "./pages/itemDetail";
import CategoryPage from "./pages/categoryPage";
import { items } from "./data/items";

export default function App() {
  const handleBuy = (item) => {
    alert(`Simulated purchase of ${item.title}`);
  };

  return (
    <>
      <Navbar />

      <div className="max-w-7xl mx-auto px-6 py-10">
        <Routes>
          <Route
            path="/"
            element={
              <div>
                <h1 className="text-4xl font-bold mb-6">Marketplace Products</h1>

                <div className="grid grid-cols-1 sm:grid-cols-2 md:grid-cols-3 gap-10">
                  {items.map((item) => (
                    <ItemCard key={item.id} item={item} onBuy={handleBuy} />
                  ))}
                </div>
              </div>
            }
          />

          <Route path="/item/:id" element={<ItemDetail />} />
          <Route path="/category/:type" element={<CategoryPage />} />
        </Routes>
      </div>
    </>
  );
}
