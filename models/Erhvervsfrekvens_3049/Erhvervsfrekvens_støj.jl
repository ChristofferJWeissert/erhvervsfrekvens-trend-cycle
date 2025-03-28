module Erhvervsfrekvens_støj

export state_space, model_specs

using LinearAlgebra


function state_space(θ)
    # Unpack parameters from θ:
    # θ = [ψ₁, ψ₂, μ₁, θ, η₁, η₀, σ_{ε*}, σ_{ε^c}, σ_{shortage}, σ_{E}]
    ψ₁      = θ[1]
    ψ₂      = θ[2]
    μ₁      = θ[3]
    θ_val   = θ[4]  
    η₁      = θ[5]
    η₀      = θ[6]
    σ_ε_star = θ[7]
    σ_ε_c   = θ[8]
    σ_shortage = θ[9]
    σ_E     = θ[10]
    
    # Observation equation:
    Z = [1.0   1.0   0.0;
         0.0   η₁    0.0]  

    # Measurement noise covariance
    H = [σ_E^2      0.0;
         0.0  σ_shortage^2]
    # Observation intercept:
    d = [0.0; η₀]
    
    # State equation:
    T = [1.0  0.0  0.0;
         0.0  ψ₁   ψ₂;
         0.0  1.0  0.0]
    c = [ μ₁    0.0;
          0.0   θ_val;
          0.0   0.0 ]

    
    # State noise covariance:
    Q = [σ_ε_star^2  0.0;
         0.0  σ_ε_c^2]

    R = [1.0 0.0 ;
         0.0 1.0 ;
        0.0 0.0 ]
    
  
    
    # Diffuse initialization: we assume the trend (first state) is nonstationary.
    P_diffuse = zeros(3, 3)
    P_diffuse[1,1] = 1.0  # Set the variance of E_t^* diffuse part.
    
    return Z, H, d, T, R, Q, c, P_diffuse
end


function model_specs()
    # Parameter names in order:
    θ_elements = ["ψ₁", "ψ₂", "μ₁", "θ", "η₁", "η₀", "σ_{ε*}", "σ_{ε^c}", "σ_{shortage}", "σ_{E}"]
    # State variable names:
    α_elements = ["E_t^*", "E_t^c", "E_{t-1}^c"]
    

    θ_true = [
        0.82293, # ψ1
        0.06414, # ψ2
        -0.44027, # μ1
        -3.22096, # θ
        0.00552, # η1
        0.02436, # η0
        0.08239, # σ_star 
        0.34957, # σ_c
        0.02609,  # σ_short
        0.01     # σ_E
    ]
    
    # Define support for each parameter:
    support = [
        -1.0    1.0;    # ψ₁
       -1.0    1.0;    # ψ₂ 
       -10.0   10.0;    # μ₁
       -10.0   10.0;    # θ
        -10.0    10.0;    # η₁ 
       -10.0   10.0;    # η₀
        0.0    Inf;    # σ_{ε*}
        0.0    Inf;    # σ_{ε^c}
        0.0    Inf;     # σ_{shortage}
        0.0    Inf;     # σ_{E}
    ]
    
    prior_distributions = ("uniform", "uniform", "uniform", "uniform", "uniform", "uniform", "inverse_gamma", "inverse_gamma", "inverse_gamma", "inverse_gamma")
    prior_hyperparameters = [
         0.0   1.0;
        -0.5   1.0;
       -1.0  1.0;
       -10.0  10.0;
        -1.0   1.0;
       -1.0  1.0;
       5.0  6.0*0.08239;
       5.0  6.0*0.34957;
       5.0  6.0*0.02609;
        1e-6  1e-6
    ]
    
    prior_info = (
        support = support,
        distributions = prior_distributions,
        parameters = prior_hyperparameters
    )
    
    return (θ_elements = θ_elements, α_elements = α_elements, θ_true = θ_true, prior_info = prior_info)
end

end  # module ErhvervsfrekvensModel
