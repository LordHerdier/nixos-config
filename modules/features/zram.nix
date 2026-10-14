# modules/features/zram.nix

{ ... }:

{
  # Compressed swap in RAM. There is no disk swap on these machines, so
  # under memory pressure the kernel has nothing to fall back on and can
  # only reclaim page cache or start killing things. zram gives it slack
  # without touching the NVMe.
  zramSwap = {
    enable = true;
    algorithm = "zstd";
    # Upper bound on the uncompressed data zram will hold, as a percentage
    # of RAM. zstd gets roughly 3:1 on anonymous pages, so this costs well
    # under 50% of RAM in practice.
    memoryPercent = 50;
  };

  # zram is orders of magnitude faster than disk swap, so the defaults --
  # tuned for spinning rust -- are far too reluctant to use it.
  boot.kernel.sysctl = {
    # 180 is the recommended value for swap-on-zram: prefer evicting
    # anonymous pages to compressed RAM over dropping useful page cache.
    "vm.swappiness" = 180;
    # Read-ahead on swap-in buys nothing when "swap" is RAM; 0 disables it.
    "vm.page-cluster" = 0;
    # Reclaim earlier and more aggressively so bursts do not drive the
    # system into a stall before zram is put to work.
    "vm.watermark_boost_factor" = 0;
    "vm.watermark_scale_factor" = 125;
  };
}
