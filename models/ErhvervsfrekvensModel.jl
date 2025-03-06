module ErhvervsfrekvensModel

export state_space, model_specs

using LinearAlgebra


function state_space(θ)
    # Unpack parameters from θ:
    # θ = [ψ₁, ψ₂, μ₁, θ, η₁, η₀, σ_{ε*}, σ_{ε^c}, σ_{shortage}]
    ψ₁      = θ[1]
    ψ₂      = θ[2]
    μ₁      = θ[3]
    θ_val   = θ[4]   
    η₁      = θ[5]
    η₀      = θ[6]
    σ_ε_star = θ[7]
    σ_ε_c   = θ[8]
    σ_shortage = θ[9]
    
    # Observation equation:
    Z = [1.0   1.0   0.0;
         0.0   η₁    0.0]  

    # Measurement noise covariance
    H = [0.0      0.0;
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
    θ_elements = ["ψ₁", "ψ₂", "μ₁", "θ", "η₁", "η₀", "σ_{ε*}", "σ_{ε^c}", "σ_{shortage}"]
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
        0.02609  # σ_short
    ]
    
    # Define support for each parameter:
    support = [
        -1.0    2.0;    # ψ₁
       -1.0    2.0;    # ψ₂ 
       -10.0   10.0;    # μ₁
       -10.0   10.0;    # θ
        -10.0    10.0;    # η₁ 
       -10.0   10.0;    # η₀
        0.0    Inf;    # σ_{ε*}
        0.0    Inf;    # σ_{ε^c}
        0.0    Inf     # σ_{shortage}
    ]
    
    prior_distributions = ("uniform", "uniform", "uniform", "uniform", "uniform", "uniform", "normal", "inverse_gamma", "inverse_gamma")
    prior_hyperparameters = [
         0.0   2.0;  # ψ₁
        -0.5   1.0;  # ψ₂
       -1.0  1.0;    # μ₁
       -10.0  10.0;  # θ
        -1.0   1.0;  # η₁
       -1.0  1.0;    # η₀
        # 2.0  3.0*0.08239;  # σ_star
        0.08239  0.00001;  #  # σ_star very informative prior on σ_star
        2.0  3.0*0.34957;  # σ_c
        2.0  3.0*0.02609;  # σ_shortage
        # 0.34957  0.00001;  # σ_c
        # 0.02609  0.00001   # σ_shortage
    ]
    
    prior_info = (
        support = support,
        distributions = prior_distributions,
        parameters = prior_hyperparameters
    )
    
    return (θ_elements = θ_elements, α_elements = α_elements, θ_true = θ_true, prior_info = prior_info)
end

end  # module ErhvervsfrekvensModel





# ###############################################
# ### Holding variances fixed at old estimate ###  
# ###############################################


# function state_space(θ)
#     # Unpack parameters from θ:
#     # θ = [ψ₁, ψ₂, μ₁, θ, η₁, η₀]
#     ψ₁    = θ[1]
#     ψ₂    = θ[2]
#     μ₁    = θ[3]
#     θ_val = θ[4]   # coefficient on u^c_{t-1}
#     η₁    = θ[5]
#     η₀    = θ[6]
    
#     # Set variances to their true fixed values:
#     σ_ε_star   = 0.08239
#     σ_ε_c      = 0.34957
#     σ_shortage = 0.02609
    
#     # Observation equation:
#     Z = [1.0   1.0   0.0;
#          0.0   η₁    0.0]
    
#     # Measurement noise covariance:
#     H = [0.0        0.0;
#          0.0  σ_shortage^2]
    
#     # Observation intercept:
#     d = [0.0; η₀]
    
#     # State equation:
#     T = [1.0  0.0  0.0;
#          0.0  ψ₁   ψ₂;
#          0.0  1.0  0.0]
#     c = [ μ₁    0.0;
#           0.0   θ_val;
#           0.0   0.0 ]
    
#     # State noise covariance:
#     Q = [σ_ε_star^2   0.0;
#          0.0      σ_ε_c^2]
    
#     R = [1.0  0.0;
#          0.0  1.0;
#          0.0  0.0]
    
#     # Diffuse initialization: assume the trend (first state) is nonstationary.
#     P_diffuse = zeros(3, 3)
#     P_diffuse[1, 1] = 1.0  # Diffuse variance for E_t^*
    
#     return Z, H, d, T, R, Q, c, P_diffuse
# end


# function model_specs()
#     # Estimated parameter names (variances are fixed and not estimated):
#     θ_elements = ["ψ₁", "ψ₂", "μ₁", "θ", "η₁", "η₀"]
#     # State variable names:
#     α_elements = ["E_t^*", "E_t^c", "E_{t-1}^c"]
    
#     # True values for the estimated parameters:
#     θ_true = [
#         0.82293,  # ψ₁
#         0.06414,  # ψ₂
#         -0.44027, # μ₁
#         -3.22096, # θ
#         0.00552,  # η₁
#         0.02436   # η₀
#     ]
    
#     # Support for each estimated parameter:
#     support = [
#         -1.0   2.0;    # ψ₁
#         -1.0   2.0;    # ψ₂
#        -10.0  10.0;    # μ₁
#        -10.0  10.0;    # θ
#        -10.0  10.0;    # η₁
#        -10.0  10.0     # η₀
#     ]
    
#     prior_distributions = ("uniform", "uniform", "uniform", "uniform", "uniform", "uniform")
#     prior_hyperparameters = [
#          0.0   2.0;
#         -0.5   1.0;
#         -1.0   1.0;
#        -10.0  10.0;
#         -1.0   1.0;
#         -1.0   1.0
#     ]
    
#     prior_info = (
#         support = support,
#         distributions = prior_distributions,
#         parameters = prior_hyperparameters
#     )
    
#     return (θ_elements = θ_elements, α_elements = α_elements, θ_true = θ_true, prior_info = prior_info)
# end

# end  # module ErhvervsfrekvensModel

