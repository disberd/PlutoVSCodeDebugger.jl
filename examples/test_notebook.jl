### A Pluto.jl notebook ###
# v0.19.27

using Markdown
using InteractiveUtils

# ╔═╡ 28fa6890-3ce9-11ee-36bd-6371c1775e91
begin
	using PlutoDevMacros
end

# ╔═╡ bd6394e1-ca2b-4079-8b3a-710cef6b4dda
@fromparent begin
	using PackageModule # This just use the parent module (PlutoVSCodeDebugger)
end

# ╔═╡ bd4e372c-49ba-49a8-bab2-e056ccab6fc4
include("included_file.jl") # This simply brings `included_function` into scope

# ╔═╡ 68f705bb-9c8f-4eae-8a52-a390a3568152
@connect_vscode begin
	#= Paste VSCode snippet here =#
end

# ╔═╡ 0cbfd57c-16f6-44b3-9983-44cb5802b88c
md"""
## Debug code inside a package
"""

# ╔═╡ 0c15167b-98e2-499d-bf5e-470994553f91
# @vscedit PlutoVSCodeDebugger.open_file_vscode("path", 1) # This open a file in this project

# ╔═╡ b8f82bc0-db2e-410c-98af-3d7f2251c526
# @run PlutoVSCodeDebugger.open_file_vscode(sum)

# ╔═╡ 49e6883f-4229-4225-bc05-3f97be286ae5
md"""
## Debug code directly included from a file
"""

# ╔═╡ b2322d22-c92d-4092-8a64-6ca2284beb77
# @vscedit included_function(1) # This open a file in directly included in the notebook

# ╔═╡ d3f48772-e700-4978-a03a-d6621cf44de9
# @run included_function(1)

# ╔═╡ 6d5e95b6-2223-4dd0-acd5-22b4ef6ae980
md"""
## Debug code defined in the notebook
Debugging code defined inside the notebook is more tricky because you can not put breakpoints inside the function.
The only way to do it is by usint the `@enter` macro and stepping manually
"""

# ╔═╡ 16e0a5ba-3571-4c58-9f57-8def8d57154a
function notebook_function(x)
	A = "$x"
	B = A * " Magic Cookies"
	return B
end

# ╔═╡ 60438e86-70cf-4622-a55d-4c930c1ac922
# @enter notebook_function(3)

# ╔═╡ 00000000-0000-0000-0000-000000000001
PLUTO_PROJECT_TOML_CONTENTS = """
[deps]
PlutoDevMacros = "a0499f29-c39b-4c5c-807c-88074221b949"

[compat]
PlutoDevMacros = "~0.5.5"
"""

# ╔═╡ 00000000-0000-0000-0000-000000000002
PLUTO_MANIFEST_TOML_CONTENTS = """
# This file is machine-generated - editing it directly is not advised

julia_version = "1.9.2"
manifest_format = "2.0"
project_hash = "826daeda7b954256c3315394d715e1379bcb080a"

[[deps.ArgTools]]
uuid = "0dad84c5-d112-42e6-8d28-ef12dabb789f"
version = "1.1.1"

[[deps.Artifacts]]
uuid = "56f22d72-fd6d-98f1-02f0-08ddc0907c33"

[[deps.Base64]]
uuid = "2a0f44e3-6c83-55bd-87e4-b1978d98bd5f"

[[deps.Dates]]
deps = ["Printf"]
uuid = "ade2ca70-3891-5945-98fb-dc099432e06a"

[[deps.Downloads]]
deps = ["ArgTools", "FileWatching", "LibCURL", "NetworkOptions"]
uuid = "f43a241f-c20a-4ad4-852c-f6b1247861c6"
version = "1.6.0"

[[deps.FileWatching]]
uuid = "7b1f6079-737a-58dc-b8bc-7a2ca5c1b5ee"

[[deps.HypertextLiteral]]
deps = ["Tricks"]
git-tree-sha1 = "c47c5fa4c5308f27ccaac35504858d8914e102f9"
uuid = "ac1192a8-f4b3-4bfe-ba22-af5b92cd3ab2"
version = "0.9.4"

[[deps.InteractiveUtils]]
deps = ["Markdown"]
uuid = "b77e0a4c-d291-57a0-90e8-8db25a27a240"

[[deps.LibCURL]]
deps = ["LibCURL_jll", "MozillaCACerts_jll"]
uuid = "b27032c2-a3e7-50c8-80cd-2d36dbcbfd21"
version = "0.6.3"

[[deps.LibCURL_jll]]
deps = ["Artifacts", "LibSSH2_jll", "Libdl", "MbedTLS_jll", "Zlib_jll", "nghttp2_jll"]
uuid = "deac9b47-8bc7-5906-a0fe-35ac56dc84c0"
version = "7.84.0+0"

[[deps.LibGit2]]
deps = ["Base64", "NetworkOptions", "Printf", "SHA"]
uuid = "76f85450-5226-5b5a-8eaa-529ad045b433"

[[deps.LibSSH2_jll]]
deps = ["Artifacts", "Libdl", "MbedTLS_jll"]
uuid = "29816b5a-b9ab-546f-933c-edad1886dfa8"
version = "1.10.2+0"

[[deps.Libdl]]
uuid = "8f399da3-3557-5675-b5ff-fb832c97cbdb"

[[deps.Logging]]
uuid = "56ddb016-857b-54e1-b83d-db4d58db5568"

[[deps.MacroTools]]
deps = ["Markdown", "Random"]
git-tree-sha1 = "42324d08725e200c23d4dfb549e0d5d89dede2d2"
uuid = "1914dd2f-81c6-5fcd-8719-6d5c9610ff09"
version = "0.5.10"

[[deps.Markdown]]
deps = ["Base64"]
uuid = "d6f4376e-aef5-505a-96c1-9c027394607a"

[[deps.MbedTLS_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "c8ffd9c3-330d-5841-b78e-0817d7145fa1"
version = "2.28.2+0"

[[deps.MozillaCACerts_jll]]
uuid = "14a3606d-f60d-562e-9121-12d972cd8159"
version = "2022.10.11"

[[deps.NetworkOptions]]
uuid = "ca575930-c2e3-43a9-ace4-1e988b2c1908"
version = "1.2.0"

[[deps.Pkg]]
deps = ["Artifacts", "Dates", "Downloads", "FileWatching", "LibGit2", "Libdl", "Logging", "Markdown", "Printf", "REPL", "Random", "SHA", "Serialization", "TOML", "Tar", "UUIDs", "p7zip_jll"]
uuid = "44cfe95a-1eb2-52ea-b672-e2afdf69b78f"
version = "1.9.2"

[[deps.PlutoDevMacros]]
deps = ["HypertextLiteral", "InteractiveUtils", "MacroTools", "Markdown", "Pkg", "Random", "TOML"]
git-tree-sha1 = "44b59480bdd690eb31b32f4ba3418e0731145cea"
uuid = "a0499f29-c39b-4c5c-807c-88074221b949"
version = "0.5.5"

[[deps.Printf]]
deps = ["Unicode"]
uuid = "de0858da-6303-5e67-8744-51eddeeeb8d7"

[[deps.REPL]]
deps = ["InteractiveUtils", "Markdown", "Sockets", "Unicode"]
uuid = "3fa0cd96-eef1-5676-8a61-b3b8758bbffb"

[[deps.Random]]
deps = ["SHA", "Serialization"]
uuid = "9a3f8284-a2c9-5f02-9a11-845980a1fd5c"

[[deps.SHA]]
uuid = "ea8e919c-243c-51af-8825-aaa63cd721ce"
version = "0.7.0"

[[deps.Serialization]]
uuid = "9e88b42a-f829-5b0c-bbe9-9e923198166b"

[[deps.Sockets]]
uuid = "6462fe0b-24de-5631-8697-dd941f90decc"

[[deps.TOML]]
deps = ["Dates"]
uuid = "fa267f1f-6049-4f14-aa54-33bafae1ed76"
version = "1.0.3"

[[deps.Tar]]
deps = ["ArgTools", "SHA"]
uuid = "a4e569a6-e804-4fa4-b0f3-eef7a1d5b13e"
version = "1.10.0"

[[deps.Tricks]]
git-tree-sha1 = "aadb748be58b492045b4f56166b5188aa63ce549"
uuid = "410a4b4d-49e4-4fbc-ab6d-cb71b17b3775"
version = "0.1.7"

[[deps.UUIDs]]
deps = ["Random", "SHA"]
uuid = "cf7118a7-6976-5b1a-9a39-7adc72f591a4"

[[deps.Unicode]]
uuid = "4ec0a83e-493e-50e2-b9ac-8f72acf5a8f5"

[[deps.Zlib_jll]]
deps = ["Libdl"]
uuid = "83775a58-1f1d-513f-b197-d71354ab007a"
version = "1.2.13+0"

[[deps.nghttp2_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "8e850ede-7688-5339-a07c-302acd2aaf8d"
version = "1.48.0+0"

[[deps.p7zip_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "3f19e933-33d8-53b3-aaab-bd5110c3b7a0"
version = "17.4.0+0"
"""

# ╔═╡ Cell order:
# ╠═28fa6890-3ce9-11ee-36bd-6371c1775e91
# ╠═bd6394e1-ca2b-4079-8b3a-710cef6b4dda
# ╠═68f705bb-9c8f-4eae-8a52-a390a3568152
# ╟─0cbfd57c-16f6-44b3-9983-44cb5802b88c
# ╠═0c15167b-98e2-499d-bf5e-470994553f91
# ╠═b8f82bc0-db2e-410c-98af-3d7f2251c526
# ╟─49e6883f-4229-4225-bc05-3f97be286ae5
# ╠═bd4e372c-49ba-49a8-bab2-e056ccab6fc4
# ╠═b2322d22-c92d-4092-8a64-6ca2284beb77
# ╠═d3f48772-e700-4978-a03a-d6621cf44de9
# ╟─6d5e95b6-2223-4dd0-acd5-22b4ef6ae980
# ╠═16e0a5ba-3571-4c58-9f57-8def8d57154a
# ╠═60438e86-70cf-4622-a55d-4c930c1ac922
# ╟─00000000-0000-0000-0000-000000000001
# ╟─00000000-0000-0000-0000-000000000002
