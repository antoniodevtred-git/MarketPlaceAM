import escrowAbi from "../abi/EscrowMarketplace.json";
import { getAddress } from "viem";

export const ESCROW_ADDRESS = getAddress(
  "0x0000000000000000000000000000000000000000" // cambia esto cuando despleguemos
);

export const ESCROW_ABI = escrowAbi.abi;
