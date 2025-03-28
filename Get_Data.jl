# Random number generation and related functions
using XLSX
function get_data(PRBANK, Filtration_period, Estimation_period, lags_uᶜ = 1)
    
    Erhvervsfrekvens = [:ERHFRK2_3049] # Navnet på kolonnen for erhvervsfrekvens (første element i Y)
    Shortage = [:ARBBEK] # Navnet på kolonnen for mangel (andet element i Y)
    Leave3049 = [:DORLOVMVFRK3049] # Navnet på kolonnen for Δleave3049 (første element i Z)
    U_lagged = [:bulgrad_gab] # Navnet på kolonnen for forsinket arbejdsløshedsgab (andet element i Z)

    # Hent data
    file_path = "G:\\Konjunktur\\Produktionsgab\\Gekko\\Data\\Input\\gabinput_pr$PRBANK.xlsx"
    sheet_name = "Data"
    wb = XLSX.readxlsx(file_path)
    ws = wb[sheet_name]
    raw_data = XLSX.getdata(ws)
    df = DataFrame(raw_data,:auto)
    df[1, :x1] = "PERIOD"
    header = [string(df[1, col]) for col in names(df)]
    df = df[2:end, :]
    mapping = Dict(zip(names(df), Symbol.(header)))
    rename!(df, mapping)
    
    firstdatapoint_filt = findfirst(==( Filtration_period[1]), df[!, :PERIOD])
    lastdatapoint_filt = findfirst(==( Filtration_period[2]), df[!, :PERIOD])
    df_filt = df[firstdatapoint_filt:lastdatapoint_filt,:]
    firstdatapoint_est = findfirst(==( Estimation_period[1]), df[!, :PERIOD]) 
    lastdatapoint_est = findfirst(==( Estimation_period[2]), df[!, :PERIOD])
    df_est = df[firstdatapoint_est:lastdatapoint_est,:]
    
    E = Array{Float64}(df_filt[:,Erhvervsfrekvens])
    shortage = Array{Float64}(df_filt[:,Shortage])
    leave3049 = Array{Float64}(df_filt[:,Leave3049])
    
    # Hent lagged arbejdsløshedsgab
    file_path_gab = "G:\\Konjunktur\\Produktionsgab\\Gekko\\Resultater\\Struk_led\\Excel\\ulb_pr$(PRBANK)_f.xlsx" 
    sheet_name_gab = 1  
    wb_gab = XLSX.readxlsx(file_path_gab)
    ws_gab = wb_gab[sheet_name_gab]
    raw_data_gab = XLSX.getdata(ws_gab)
    df_gab = DataFrame(raw_data_gab,:auto)
    df_gab[1, :x1] = "PERIOD"
    header_gab = [string(df_gab[1, col]) for col in names(df_gab)]
    df_gab = df_gab[2:end, :]
    mapping_gab = Dict(zip(names(df_gab), Symbol.(header_gab)))
    rename!(df_gab, mapping_gab)
    
    ugab_period = [ string(x[1:4], "(", x[end], ")") for x in Filtration_period ]
    firstdatapoint_ugab = findfirst(==( ugab_period[1]), df_gab[!, :PERIOD]) - lags_uᶜ
    lastdatapoint_ugab = findfirst(==( ugab_period[2]), df_gab[!, :PERIOD]) - lags_uᶜ
    df_gab = df_gab[firstdatapoint_ugab:lastdatapoint_ugab,:]
    
    df_gab
    u_lagged = Array{Float64}(df_gab[:,U_lagged])
    
    T_est = nrow(df_est)
    elements_in_y = 2
    elements_in_z = 2
    Y_est = zeros(elements_in_y, T_est)
    Z_est = zeros(elements_in_z, T_est)
    
    for t in 1:T_est
        Y_est[:, t] = [E[t]; shortage[t]]
        Z_est[:, t] = [leave3049[t]; u_lagged[t]]
    end
    
    print("\nDimensions of Y_est: $(size(Y_est))")
    print("\nDimensions of X_est: $(size(Z_est))")
    
    T_filt = nrow(df_filt)
    Y_filt = zeros(elements_in_y, T_filt)
    Z_filt = zeros(elements_in_z, T_filt)
    
    
    for t in 1:T_filt
        Y_filt[:, t] = [E[t]; shortage[t]]
        Z_filt[:, t] = [leave3049[t]; u_lagged[t]]
    end
    
    print("\nDimensions of Y_filt: $(size(Y_filt))")
    print("\nDimensions of X_filt: $(size(Z_filt))")
    
    
    return Y_est, Z_est, Y_filt, Z_filt, df_filt
end

function get_data_1629(PRBANK, Filtration_period, Estimation_period, lags_shortage = 1)
    
    Erhvervsfrekvens = [:ERHFRK2_1629] # Navnet på kolonnen for erhvervsfrekvens (første element i Y)
    Shortage = [:ARBBEK] # Navnet på kolonnen for mangel (andet element i Y)
    Leave1629 = [:DORLOVMVFRK1629] # Navnet på kolonnen for Δleave3049 (første element i Z)
    Stud = [:DSTUDFRK1629] # Navnet på kolonnen for forsinket arbejdsløshedsgab (andet element i Z)

    # Hent data
    file_path = "G:\\Konjunktur\\Produktionsgab\\Gekko\\Data\\Input\\gabinput_pr$PRBANK.xlsx"
    sheet_name = "Data"
    wb = XLSX.readxlsx(file_path)
    ws = wb[sheet_name]
    raw_data = XLSX.getdata(ws)
    df = DataFrame(raw_data,:auto)
    df[1, :x1] = "PERIOD"
    header = [string(df[1, col]) for col in names(df)]
    df = df[2:end, :]
    mapping = Dict(zip(names(df), Symbol.(header)))
    rename!(df, mapping)
    
    firstdatapoint_filt = findfirst(==( Filtration_period[1]), df[!, :PERIOD]) - lags_shortage
    lastdatapoint_filt = findfirst(==( Filtration_period[2]), df[!, :PERIOD])
    df_filt = df[firstdatapoint_filt:lastdatapoint_filt,:]
    firstdatapoint_est = findfirst(==( Estimation_period[1]), df[!, :PERIOD]) - lags_shortage
    lastdatapoint_est = findfirst(==( Estimation_period[2]), df[!, :PERIOD])
    df_est = df[firstdatapoint_est:lastdatapoint_est,:]
    
    E = Array{Float64}(df_filt[1+lags_shortage:end,Erhvervsfrekvens])
    shortage = Array{Float64}(df_filt[1:end-lags_shortage,Shortage])
    leave1629 = Array{Float64}(df_filt[1+lags_shortage:end,Leave1629])
    stud = Array{Float64}(df_filt[1+lags_shortage:end,Stud])
    
    T_est = nrow(df_est) - lags_shortage
    elements_in_y = 2
    elements_in_z = 2
    Y_est = zeros(elements_in_y, T_est)
    Z_est = zeros(elements_in_z, T_est)
    
    for t in 1:T_est 
        Y_est[:, t] = [E[t]; shortage[t]]
        Z_est[:, t] = [leave1629[t]; stud[t]]
    end
    
    print("\nDimensions of Y_est: $(size(Y_est))")
    print("\nDimensions of X_est: $(size(Z_est))")
    
    T_filt = nrow(df_filt) - lags_shortage
    Y_filt = zeros(elements_in_y, T_filt)
    Z_filt = zeros(elements_in_z, T_filt)
    
    
    for t in 1:T_filt
        Y_filt[:, t] = [E[t]; shortage[t]]
        Z_filt[:, t] = [leave1629[t]; stud[t]]
    end
    
    print("\nDimensions of Y_filt: $(size(Y_filt))")
    print("\nDimensions of X_filt: $(size(Z_filt))")
   
    df_filt = df_filt[1+lags_shortage:end,:]

    
    return Y_est, Z_est, Y_filt, Z_filt, df_filt
end

function get_data_TFP(PRBANK, Filtration_period, Estimation_period, lags_CU = 1)
    
    TFP_name = [:LOGTFP] 
    CU_name = [:LEDKAP_DM] 
    
    # Hent data
    file_path = "G:\\Konjunktur\\Produktionsgab\\Gekko\\Data\\Input\\gabinput_pr$PRBANK.xlsx"
    sheet_name = "Data"
    wb = XLSX.readxlsx(file_path)
    ws = wb[sheet_name]
    raw_data = XLSX.getdata(ws)
    df = DataFrame(raw_data,:auto)
    df[1, :x1] = "PERIOD"
    header = [string(df[1, col]) for col in names(df)]
    df = df[2:end, :]
    mapping = Dict(zip(names(df), Symbol.(header)))
    rename!(df, mapping)
    
    firstdatapoint_filt = findfirst(==( Filtration_period[1]), df[!, :PERIOD]) - lags_CU
    lastdatapoint_filt = findfirst(==( Filtration_period[2]), df[!, :PERIOD])
    df_filt = df[firstdatapoint_filt:lastdatapoint_filt,:]
    firstdatapoint_est = findfirst(==( Estimation_period[1]), df[!, :PERIOD]) - lags_CU
    lastdatapoint_est = findfirst(==( Estimation_period[2]), df[!, :PERIOD])
    df_est = df[firstdatapoint_est:lastdatapoint_est,:]
    
    TFP = Array{Float64}(df_filt[1+lags_CU:end,TFP_name])
    TFP_lagged = Array{Float64}(df_filt[1:end-lags_CU,TFP_name])
    CU = Array{Float64}(df_filt[1+lags_CU:end,CU_name])
    CU_lagged = Array{Float64}(df_filt[1+lags_CU:end,CU_name])

    T_est = nrow(df_est) - lags_CU
    elements_in_y = 2
    elements_in_z = 2
    Y_est = zeros(elements_in_y, T_est)
    Z_est = zeros(elements_in_z, T_est)
    
    for t in 1:T_est 
        Y_est[:, t] = [TFP[t]; CU[t]]
        Z_est[:, t] = [TFP_lagged[t]; CU_lagged[t]]
    end
    
    print("\nDimensions of Y_est: $(size(Y_est))")
    print("\nDimensions of X_est: $(size(Z_est))")
    
    T_filt = nrow(df_filt) - lags_CU
    Y_filt = zeros(elements_in_y, T_filt)
    Z_filt = zeros(elements_in_z, T_filt)
    
    
    for t in 1:T_filt
        Y_filt[:, t] = [TFP[t]; CU[t]]
        Z_filt[:, t] = [TFP_lagged[t]; CU_lagged[t]]
    end
    
    print("\nDimensions of Y_filt: $(size(Y_filt))")
    print("\nDimensions of X_filt: $(size(Z_filt))")

    df_filt = df_filt[1+lags_CU:end,:]

    return Y_est, Z_est, Y_filt, Z_filt, df_filt
end

function get_data_ledighed(PRBANK, Filtration_period, Estimation_period, lags_y = 2)
    
    u_name = [:ULB2GRAD] # Navnet på kolonnen for erhvervsfrekvens (første element i Y)
    w_p_name = [:D4_LNAPCP] # Navnet på kolonnen for shortage (andet element i Y)
    LOGRPRTOT_name = [:D4_LOGRPRTOT]
    LOGEFKRKS_name = [:D4_LOGEFKRKS]
    LOGPROBX_name = [:D4_LOGPROBX]
    LOGTOT_name = [:D4_LOGTOT]

    # Hent data
    file_path = "G:\\Konjunktur\\Produktionsgab\\Gekko\\Data\\Input\\gabinput_pr$PRBANK.xlsx"
    sheet_name = "Data"
    wb = XLSX.readxlsx(file_path)
    ws = wb[sheet_name]
    raw_data = XLSX.getdata(ws)
    df = DataFrame(raw_data,:auto)
    df[1, :x1] = "PERIOD"
    header = [string(df[1, col]) for col in names(df)]
    df = df[2:end, :]
    mapping = Dict(zip(names(df), Symbol.(header)))
    rename!(df, mapping)
    
    firstdatapoint_filt = findfirst(==( Filtration_period[1]), df[!, :PERIOD]) - lags_y
    lastdatapoint_filt = findfirst(==( Filtration_period[2]), df[!, :PERIOD])
    df_filt = df[firstdatapoint_filt:lastdatapoint_filt,:]
    firstdatapoint_est = findfirst(==( Estimation_period[1]), df[!, :PERIOD]) - lags_y
    lastdatapoint_est = findfirst(==( Estimation_period[2]), df[!, :PERIOD])
    df_est = df[firstdatapoint_est:lastdatapoint_est,:]
    
    u = Array{Float64}(df_filt[1+lags_y:end,u_name])
    u_lagged = Array{Float64}(df_filt[1:end-lags_y,u_name])
    w_p = Array{Float64}(df_filt[1+lags_y:end,w_p_name])
    w_p_lagged = Array{Float64}(df_filt[1:end-lags_y,w_p_name])
    logprtot = Array{Float64}(df_filt[1+lags_y:end,LOGRPRTOT_name])
    logefkrks = Array{Float64}(df_filt[1+lags_y:end,LOGEFKRKS_name])
    logprobx = Array{Float64}(df_filt[1+lags_y:end,LOGPROBX_name])
    logtot = Array{Float64}(df_filt[1+lags_y:end,LOGTOT_name])
    
    T_est = nrow(df_est) - lags_y
    elements_in_y = 2
    elements_in_z = 7
    Y_est = zeros(elements_in_y, T_est)
    Z_est = zeros(elements_in_z, T_est)
    
    for t in 1:T_est 
        Y_est[:, t] = [u[t]; w_p[t]]
        Z_est[:, t] = [logprtot[t]; logefkrks[t]; logprobx[t]; logtot[t];u_lagged[t];w_p_lagged[t];1.0]
    end
    
    print("\nDimensions of Y_est: $(size(Y_est))")
    print("\nDimensions of X_est: $(size(Z_est))")
    
    T_filt = nrow(df_filt) - lags_y
    Y_filt = zeros(elements_in_y, T_filt)
    Z_filt = zeros(elements_in_z, T_filt)
    
    
    for t in 1:T_filt 
        Y_filt[:, t] = [u[t]; w_p[t]]
        Z_filt[:, t] = [logprtot[t]; logefkrks[t]; logprobx[t]; logtot[t];u_lagged[t];w_p_lagged[t];1.0]
    end
    
    print("\nDimensions of Y_filt: $(size(Y_filt))")
    print("\nDimensions of X_filt: $(size(Z_filt))")

    df_filt = df_filt[1+lags_y:end,:]

    return Y_est, Z_est, Y_filt, Z_filt, df_filt
end