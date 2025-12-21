import { readContract, writeContract, waitForTransactionReceipt } from "@wagmi/core";
import { ESCROW_ABI, ESCROW_ADDRESS } from "./contract";
import { config } from "./config";

// Obtener datos del item desde el Smart Contract
export async function getItem(itemId) {
  return await readContract(config, {
    address: ESCROW_ADDRESS,
    abi: ESCROW_ABI,
    functionName: "getItem",
    args: [itemId],
  });
}

// Iniciar compra (con envío de ETH)
export async function startPurchase(itemId, ethAmount) {
  const tx = await writeContract(config, {
    address: ESCROW_ADDRESS,
    abi: ESCROW_ABI,
    functionName: "startPurchase",
    args: [itemId, ethAmount],
    value: ethAmount,
  });

  return waitForTransactionReceipt(config, { hash: tx });
}

// Confirmar compra
export async function confirmPurchase(itemId) {
  const tx = await writeContract(config, {
    address: ESCROW_ADDRESS,
    abi: ESCROW_ABI,
    functionName: "confirmPurchase",
    args: [itemId],
  });

  return waitForTransactionReceipt(config, { hash: tx });
}

// Cancelar compra
export async function cancelPurchase(itemId) {
  const tx = await writeContract(config, {
    address: ESCROW_ADDRESS,
    abi: ESCROW_ABI,
    functionName: "cancelPurchase",
    args: [itemId],
  });

  return waitForTransactionReceipt(config, { hash: tx });
}
