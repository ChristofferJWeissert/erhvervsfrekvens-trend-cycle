module modelTFP

export state_space, model_specs

using LinearAlgebra


function state_space(θ)
    # Unpack parameters from θ:
    # θ = [ψ₁, ψ₂, θ₁, θ₂, σ_{ε*}, σ_{ε^c}, σ_{γ},σ_{CU}]
    ψ₁       = θ[1]
    ψ₂       = θ[2]
    θ₁       = θ[3]
    θ₂       = θ[4]   
    σ_ε_star = θ[5]
    σ_ε_c    = θ[6]
    σ_γ      = θ[7]
    σ_CU     = θ[8]
    
    # Observation equation:
    Z = [1.0   1.0   0.0   0.0;
         0.0   θ₂    0.0   0.0]  

    # Measurement noise covariance
    H = [0.0      0.0;
         0.0      σ_CU^2]

    # Observation intercept:
    d = [0.0; 0.0]
    
    # State equation:
    T = [1.0  0.0  0.0  1.0;
         0.0  ψ₁   ψ₂  0.0;
         0.0  1.0  0.0 0.0;
         0.0  0.0  0.0  1.0]

    c = [ 0.0   0.0;
          0.0   0.0;
          0.0   0.0;
          0.0   0.0]


    D = [ 0.0   0.0;
          0.0   θ₁ ]
    
    # State noise covariance:
    Q = [σ_ε_star^2  0.0 0.0;
         0.0  σ_ε_c^2 0.0;
         0.0 0.0 σ_γ^2]


    R = [1.0 0.0 1.0;
         0.0 1.0 0.0;
        0.0 0.0 0.0;
        0.0 0.0 1.0]
    
  
    
    # Diffuse initialization: we assume the trend (first state) is nonstationary.
    P_diffuse = zeros(4, 4)
    P_diffuse[1,1] = 1.0  # Set the variance of E_t^* diffuse part.
    
    return Z, H, d, T, R, Q, c, P_diffuse, D
end


function model_specs()
    # Parameter names in order:
    θ_elements = ["ψ₁", "ψ₂", "θ₁", "θ₂", "σ_{ε*}", "σ_{ε^c}", "σ_{γ}", "σ_{CU}"]
    # State variable names:
    α_elements = ["TFP_t^*", "TFP_t^c", "TFP_{t-1}^c", "γ"]

    # True parameter values (make sure scale parameters are positive)
    θ_true = [
        0.68785,   # ψ₁
        0.15969,   # ψ₂
        0.72327,   # θ₁
       -1.45691,   # θ₂
        0.00010,   # σ_{ε*}
        0.01081,   # σ_{ε^c}
        0.00027,   # σ_{γ}   (using positive value)
        0.06018    # σ_{CU}
    ]
    
    # Define support for each parameter:
    # For uniform priors the support is given by lower and upper bounds.
    # For scale parameters we use [0, Inf).
    support = [
        -1.0    2.0;     # ψ₁
        -1.0    2.0;     # ψ₂
       -10.0   10.0;     # θ₁
       -10.0   10.0;     # θ₂
         0.0    Inf;     # σ_{ε*}
         0.0    Inf;     # σ_{ε^c}
         0.0    Inf;     # σ_{γ}
         0.0    Inf      # σ_{CU}
    ]
    
    # Define prior distributions for each parameter:
    # Here we choose "uniform" for the first four and "inverse_gamma" for the four scale parameters.
    prior_distributions = (
        "uniform",       # ψ₁
        "uniform",       # ψ₂
        "uniform",       # θ₁
        "uniform",       # θ₂
        "inverse_gamma", # σ_{ε*}
        "inverse_gamma", # σ_{ε^c}
        "inverse_gamma", # σ_{γ}
        "inverse_gamma"  # σ_{CU}
    )
    
    # Define hyperparameters for each prior.
    # For a uniform distribution the hyperparameters are the lower and upper bounds.
    # For an inverse-gamma, we set (shape, scale). The numbers below are examples.
    prior_hyperparameters = [
        -1.0   2.0;      # ψ₁: uniform lower=-1.0, upper=2.0
        -1.0   2.0;      # ψ₂: uniform lower=-1.0, upper=2.0
       -10.0  10.0;      # θ₁: uniform lower=-10.0, upper=10.0
       -10.0  10.0;      # θ₂: uniform lower=-10.0, upper=10.0
        2.0   0.0003;    # σ_{ε*}: inverse_gamma with shape=2.0 and scale=0.0003  
        2.0   0.03243;   # σ_{ε^c}: inverse_gamma with shape=2.0 and scale=0.03243  
        2.0   0.00081;   # σ_{γ}: inverse_gamma with shape=2.0 and scale=0.00081  
        2.0   0.18054    # σ_{CU}: inverse_gamma with shape=2.0 and scale=0.18054  
    ]
    
    prior_info = (
        support = support,
        distributions = prior_distributions,
        parameters = prior_hyperparameters
    )
    
    return (θ_elements = θ_elements, α_elements = α_elements, θ_true = θ_true, prior_info = prior_info)
end

end  # module modelTFP




