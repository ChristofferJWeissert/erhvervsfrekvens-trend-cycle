# Random number generation and related functions

function save_results(Y,α,PRBANK,df,gab)
    # Få periodevektor og omdan til ønsket format på form yyyy(q)
    df_per = df
    df_per[!, :PERIOD] = replace.(df_per.PERIOD, r"q(\d)" => s"(\1)")

    # Klargør samlet output-matrix
    Output = zeros(size(Y,2),4)
    Output = Matrix{Any}(undef, size(Y,2), 4)  
    Output[:,1] = df_per[!,"PERIOD"] # Første søjle i output er periode-vektor
    Output[:,2] = Y[1,:]' # Anden søjle i output er faktisk erhvervsfrekvens

    Output[:,3] = α[1,:]'

    Output[:,4] = Output[:,2] .- Output[:,3] # 4. søjle i output er gabet der defineres som forskellen mellem faktisk og strukturel erhvervsfrekvens

    # Gem i excel-format
    obs_for_excel = size(Output,1) + 1
    output_file_path = "G:\\Konjunktur\\Produktionsgab\\Gekko\\Programkode\\JULIA\\Output\\$(gab)\\$(gab)_$(PRBANK).xlsx"
    XLSX.openxlsx(output_file_path, mode="w") do xf
        sheet = xf[1]
        sheet["A1"] = ""
        sheet["B1"] = "Faktisk erhvervsfrekvens"
        sheet["C1"] = "Strukturel"
        sheet["D1"] = "gab"
        sheet["A2:D$(obs_for_excel)"] = Output
    end
    print("Output has been saved and stored at $output_file_path")
end