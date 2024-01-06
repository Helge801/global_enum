defmodule GlobalEnum.TestEnums do
  use GlobalEnum

  enum(:pets, [:cat, :dog])
  enum(:pests, rat: 1)

  enum(:things, [
    :plane,
    cold_cut: "cold-cut",
    one: 1
  ])
end
