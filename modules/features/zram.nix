# modules/features/zram.nix

{ ... }:

{
  # Compressed swap in RAM; there's no disk swap, so without it memory
  # pressure can only drop page cache or kill things.
  zramSwap = {
    enable = true;
    algorithm = "zstd";
    # Cap on *uncompressed* data; at zstd's ~3:1 this uses far less RAM.
    memoryPercent = 50;
  };

  # The defaults are tuned for disk swap and too reluctant to use zram.
  boot.kernel.sysctl = {
    # Recommended for swap-on-zram: prefer swapping anon pages over
    # dropping page cache.
    "vm.swappiness" = 180;
    # No swap-in read-ahead; pointless when "swap" is RAM.
    "vm.page-cluster" = 0;
    # Reclaim earlier so bursts don't stall before zram is used.
    "vm.watermark_boost_factor" = 0;
    "vm.watermark_scale_factor" = 125;
  };
}
