defmodule GlobalEnumTest do
  use ExUnit.Case

  alias GlobalEnum.Support.TestEnums

  describe "enum/2" do
    test "generates enum function" do
      assert [
               {:aegis, "aegis"},
               {:centurion, "centurion"},
               {:eternity, "eternity"},
               {:hyperion, "hyperion"},
               {:ragnarok, "ragnarok"},
               {:seraphim, "seraphim"},
               {:valkyrie, "valkyrie"},
               {:apex_gt, "apex gt"},
               {:nebula_x, "nebula x"},
               {:zenith_xlr, "zenith xlr"}
             ] == TestEnums.cars_enum()
    end

    test "generates values function" do
      assert [
               :aegis,
               :centurion,
               :eternity,
               :hyperion,
               :ragnarok,
               :seraphim,
               :valkyrie,
               :apex_gt,
               :nebula_x,
               :zenith_xlr
             ] == TestEnums.cars()
    end

    test "generates dump values function" do
      assert [
               "aegis",
               "centurion",
               "eternity",
               "hyperion",
               "ragnarok",
               "seraphim",
               "valkyrie",
               "apex gt",
               "nebula x",
               "zenith xlr"
             ] == TestEnums.cars_dumped()
    end

    test "generates individual value functions" do
      assert :aegis == TestEnums.cars_aegis()
      assert :centurion == TestEnums.cars_centurion()
      assert :eternity == TestEnums.cars_eternity()
      assert :hyperion == TestEnums.cars_hyperion()
      assert :ragnarok == TestEnums.cars_ragnarok()
      assert :seraphim == TestEnums.cars_seraphim()
      assert :valkyrie == TestEnums.cars_valkyrie()
      assert :apex_gt == TestEnums.cars_apex_gt()
      assert :nebula_x == TestEnums.cars_nebula_x()
      assert :zenith_xlr == TestEnums.cars_zenith_xlr()
    end

    test "generates individual dump_value functions" do
      assert "aegis" == TestEnums.cars_aegis_dumped()
      assert "centurion" == TestEnums.cars_centurion_dumped()
      assert "eternity" == TestEnums.cars_eternity_dumped()
      assert "hyperion" == TestEnums.cars_hyperion_dumped()
      assert "ragnarok" == TestEnums.cars_ragnarok_dumped()
      assert "seraphim" == TestEnums.cars_seraphim_dumped()
      assert "valkyrie" == TestEnums.cars_valkyrie_dumped()
      assert "apex gt" == TestEnums.cars_apex_gt_dumped()
      assert "nebula x" == TestEnums.cars_nebula_x_dumped()
      assert "zenith xlr" == TestEnums.cars_zenith_xlr_dumped()
    end

    test "generates guards for each " do
      assert %{
               aegis: "aegis",
               centurion: "centurion",
               eternity: "eternity",
               hyperion: "hyperion",
               ragnarok: "ragnarok",
               seraphim: "seraphim",
               valkyrie: "valkyrie",
               nebula_x: "nebula x",
               zenith_xlr: "zenith xlr",
               apex_gt: "apex gt"
             } == TestEnums.cars_mapping()
    end

    # TODO
    # test "generates load function" do

    # end

    # test "generates dump function" do

    # end
  end
end
