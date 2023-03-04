addBezoarToPath()

clc

b = Bezoar.instance();
d = DataContainer.instance();

function addBezoarToPath()
    fp = which("BEZOAR.m");
    fp = fileparts(fp);

    addpath(genpath(fp))
end