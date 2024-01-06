defmodule GlobalEnum.Support.TestEnums do
  use GlobalEnum

  enum(:cars, [
    :aegis,
    :centurion,
    :eternity,
    :hyperion,
    :ragnarok,
    :seraphim,
    :valkyrie,
    apex_gt: "apex gt",
    nebula_x: "nebula x",
    zenith_xlr: "zenith xlr"
  ])
end
