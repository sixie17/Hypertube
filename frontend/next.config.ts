import type { NextConfig } from "next";

const nextConfig: NextConfig = {
  /* config options here */
  // for docker build
  output: 'standalone',
};

export default nextConfig;
