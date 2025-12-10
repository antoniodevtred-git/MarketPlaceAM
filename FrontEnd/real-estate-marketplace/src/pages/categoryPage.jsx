import { useParams } from "react-router-dom";
import { items } from "../data/items";
import ItemCard from "../components/ItemCard";

export default function CategoryPage() {
  const { type } = useParams();

  const filtered = items.filter((item) => item.type === type);

  const categoryNames = {
    real_estate: "Real Estate",
    vehicle: "Vehicles",
    luxury: "Luxury Items"
  };

  const title = categoryNames[type] || "Category";

  return (
    <div className="max-w-6xl mx-auto p-6">

      <h1 className="text-4xl font-bold mb-6">
        {title}
      </h1>

      <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 gap-8">
        {filtered.map((item) => (
          <ItemCard key={item.id} item={item} />
        ))}

        {filtered.length === 0 && (
          <p className="text-gray-500 text-xl">No items found in this category.</p>
        )}
      </div>
    </div>
  );
}

