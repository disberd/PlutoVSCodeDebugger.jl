### A Pluto.jl notebook ###
# v0.19.26

#> custom_attrs = ["hide-enabled"]

using Markdown
using InteractiveUtils

# ╔═╡ 28fa6890-3ce9-11ee-36bd-6371c1775e91
begin
	using PlutoDevMacros
	using PlutoExtras
end

# ╔═╡ bd6394e1-ca2b-4079-8b3a-710cef6b4dda
@fromparent begin
	using PackageModule.WithFunctions # The WithFunction submodule of PlutoVSCodeDebugger will also export the breakpoint related functions from JuliaInterpreter
end

# ╔═╡ b0eb2aa1-f60e-49bf-b057-38c0ed002366
md"""
# Packages
"""

# ╔═╡ 76348a39-7dcb-4703-ba60-263fa84eae90
ExtendedTableOfContents()

# ╔═╡ 19bddf77-7f36-40de-ac63-696aaf87556b
md"""
## Load PlutoVSCodeDebugger
"""

# ╔═╡ fcec92a1-d776-462d-b25d-839d145d6594
md"""
# Usage Examples
"""

# ╔═╡ b8a055a9-7de3-48d3-9184-58e7bf432417
md"""
## Connect VSCode Instance
"""

# ╔═╡ 48c7f30a-4f10-41aa-a3d6-740cfc3ad2c7
md"""
Connecting to a running vscode instance is done via the `@connect_vscode` macro. The macro expects a single begin-end block containing the connection command copied from VSCode.

When executed with no argument, the macro will simply modify its cell to include the begin-end block for convenience.
"""

# ╔═╡ 68f705bb-9c8f-4eae-8a52-a390a3568152
# @connect_vscode

# ╔═╡ 0cbfd57c-16f6-44b3-9983-44cb5802b88c
md"""
## Debug package code
"""

# ╔═╡ b5bde02b-d4b3-43bc-b467-a5850d024a9f
md"""
To debug code defined inside a package loaded within Pluto the workflow is very straightforward. One sets breakpoints in the connected VSCode and those are hit when using the `@run` macro.

To simplify opening up the desired file location associated to a method or function, one can use the `@vscedit` macro directly from the notebook. This will open the file location associated to the provided function or method in the connected VSCode instance.\
The synthax of `@vscedit` is very similar to `@edit` from InteractiveUtils, but check the docstrings for more information.
"""

# ╔═╡ 0c15167b-98e2-499d-bf5e-470994553f91
# @vscedit PlutoVSCodeDebugger.open_file_vscode("path", 1) # This open a file in this project

# ╔═╡ b8f82bc0-db2e-410c-98af-3d7f2251c526
# @run PlutoVSCodeDebugger.open_file_vscode(sum)

# ╔═╡ 49e6883f-4229-4225-bc05-3f97be286ae5
md"""
## Debug included code
"""

# ╔═╡ 9ac85b1b-9e76-4da6-a5ee-50ab5732c8e1
md"""
Debugging code that is directly included in the notebook with `include` also works equivalently to code defined inside a package.
"""

# ╔═╡ bd4e372c-49ba-49a8-bab2-e056ccab6fc4
module IncludeModule
	include("included_file.jl") # This simply brings `included_function` into scope
end

# ╔═╡ b2322d22-c92d-4092-8a64-6ca2284beb77
# @vscedit IncludeModule.included_function(1) # This opens the `included_file.jl` file

# ╔═╡ d3f48772-e700-4978-a03a-d6621cf44de9
# @run IncludeModule.included_function(1)

# ╔═╡ 6d5e95b6-2223-4dd0-acd5-22b4ef6ae980
md"""
## Debug notebook code
"""

# ╔═╡ 089cbc8a-0f12-478a-beda-9f8144d823ef
md"""
Debugging code defined inside the notebook can not be done by adding breakpoint markers in the notebook file in VSCode.

This is because Pluto internally modifies the LineNumbers of expression associated to the notebook code so a breakpoint added on the notebook file on VSCode will not be triggered when executing code from Pluto.

While not as convenient as setting breakpoints using the VSCode UI, one can still manually set breakpoint either by inserting the `@bp` macro in function definitions or by using the `@breakpoint` macro with a call signature.
"""

# ╔═╡ 16e0a5ba-3571-4c58-9f57-8def8d57154a
begin
function outer_notebook_function(x)
	A = "$x"
	B = A * " Magic Cookies " * string(inner_notebook_function(x))
	return B
end
function inner_notebook_function(x)
	C = x+1
	D = C / 10
	return inner_inner_notebook_function(x)
end
function inner_inner_notebook_function(x)
	if x < 15
		@bp # This inserts a manual breakpoint
	end
	x+2
end
end

# ╔═╡ 615a2e70-d714-49d0-98b6-60b951db1011
md"""
The cell below will set a breakpoint in the function at line 10 (the return statement) that will stop only if ``x > 10`` (``x`` is the name of the input argument)
"""

# ╔═╡ 6443c783-b6fb-4ce2-bfef-91c183c39c12
@breakpoint inner_notebook_function(3) 10 x > 15

# ╔═╡ 68c956ef-aebc-4f80-96ad-6a3c0be6bdff
@run outer_notebook_function(10) # This will stop at @bp but not at @breakpoint

# ╔═╡ cb46fdb3-41f4-4b51-ac5d-72e6b853b0be
@run outer_notebook_function(20) # This will stop at @breakpoint but not at @bp

# ╔═╡ 00000000-0000-0000-0000-000000000001
PLUTO_PROJECT_TOML_CONTENTS = """
[deps]
PlutoDevMacros = "a0499f29-c39b-4c5c-807c-88074221b949"
PlutoExtras = "ed5d0301-4775-4676-b788-cf71e66ff8ed"

[compat]
PlutoDevMacros = "~0.5.5"
PlutoExtras = "~0.7.5"
"""

# ╔═╡ 00000000-0000-0000-0000-000000000002
PLUTO_MANIFEST_TOML_CONTENTS = """
# This file is machine-generated - editing it directly is not advised

julia_version = "1.9.2"
manifest_format = "2.0"
project_hash = "f60084fd52f27839882413854c7531476180921f"

[[deps.AbstractPlutoDingetjes]]
deps = ["Pkg"]
git-tree-sha1 = "91bd53c39b9cbfb5ef4b015e8b582d344532bd0a"
uuid = "6e696c72-6542-2067-7265-42206c756150"
version = "1.2.0"

[[deps.ArgTools]]
uuid = "0dad84c5-d112-42e6-8d28-ef12dabb789f"
version = "1.1.1"

[[deps.Artifacts]]
uuid = "56f22d72-fd6d-98f1-02f0-08ddc0907c33"

[[deps.Base64]]
uuid = "2a0f44e3-6c83-55bd-87e4-b1978d98bd5f"

[[deps.ColorTypes]]
deps = ["FixedPointNumbers", "Random"]
git-tree-sha1 = "eb7f0f8307f71fac7c606984ea5fb2817275d6e4"
uuid = "3da002f7-5984-5a60-b8a6-cbb66c0b333f"
version = "0.11.4"

[[deps.CompilerSupportLibraries_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "e66e0078-7015-5450-92f7-15fbd957f2ae"
version = "1.0.5+0"

[[deps.Dates]]
deps = ["Printf"]
uuid = "ade2ca70-3891-5945-98fb-dc099432e06a"

[[deps.Downloads]]
deps = ["ArgTools", "FileWatching", "LibCURL", "NetworkOptions"]
uuid = "f43a241f-c20a-4ad4-852c-f6b1247861c6"
version = "1.6.0"

[[deps.FileWatching]]
uuid = "7b1f6079-737a-58dc-b8bc-7a2ca5c1b5ee"

[[deps.FixedPointNumbers]]
deps = ["Statistics"]
git-tree-sha1 = "335bfdceacc84c5cdf16aadc768aa5ddfc5383cc"
uuid = "53c48c17-4a7d-5ca2-90c5-79b7896eea93"
version = "0.8.4"

[[deps.Hyperscript]]
deps = ["Test"]
git-tree-sha1 = "8d511d5b81240fc8e6802386302675bdf47737b9"
uuid = "47d2ed2b-36de-50cf-bf87-49c2cf4b8b91"
version = "0.0.4"

[[deps.HypertextLiteral]]
deps = ["Tricks"]
git-tree-sha1 = "c47c5fa4c5308f27ccaac35504858d8914e102f9"
uuid = "ac1192a8-f4b3-4bfe-ba22-af5b92cd3ab2"
version = "0.9.4"

[[deps.IOCapture]]
deps = ["Logging", "Random"]
git-tree-sha1 = "d75853a0bdbfb1ac815478bacd89cd27b550ace6"
uuid = "b5f81e59-6552-4d32-b1f0-c071b021bf89"
version = "0.2.3"

[[deps.InteractiveUtils]]
deps = ["Markdown"]
uuid = "b77e0a4c-d291-57a0-90e8-8db25a27a240"

[[deps.JSON]]
deps = ["Dates", "Mmap", "Parsers", "Unicode"]
git-tree-sha1 = "31e996f0a15c7b280ba9f76636b3ff9e2ae58c9a"
uuid = "682c06a0-de6a-54ab-a142-c8b1cf79cde6"
version = "0.21.4"

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

[[deps.LinearAlgebra]]
deps = ["Libdl", "OpenBLAS_jll", "libblastrampoline_jll"]
uuid = "37e2e46d-f89d-539d-b4ee-838fcccc9c8e"

[[deps.Logging]]
uuid = "56ddb016-857b-54e1-b83d-db4d58db5568"

[[deps.MIMEs]]
git-tree-sha1 = "65f28ad4b594aebe22157d6fac869786a255b7eb"
uuid = "6c6e2e6c-3030-632d-7369-2d6c69616d65"
version = "0.1.4"

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

[[deps.Mmap]]
uuid = "a63ad114-7e13-5084-954f-fe012c677804"

[[deps.MozillaCACerts_jll]]
uuid = "14a3606d-f60d-562e-9121-12d972cd8159"
version = "2022.10.11"

[[deps.NetworkOptions]]
uuid = "ca575930-c2e3-43a9-ace4-1e988b2c1908"
version = "1.2.0"

[[deps.OpenBLAS_jll]]
deps = ["Artifacts", "CompilerSupportLibraries_jll", "Libdl"]
uuid = "4536629a-c528-5b80-bd46-f80d51c5b363"
version = "0.3.21+4"

[[deps.OrderedCollections]]
git-tree-sha1 = "85f8e6578bf1f9ee0d11e7bb1b1456435479d47c"
uuid = "bac558e1-5e72-5ebc-8fee-abe8a469f55d"
version = "1.4.1"

[[deps.Parsers]]
deps = ["Dates", "PrecompileTools", "UUIDs"]
git-tree-sha1 = "716e24b21538abc91f6205fd1d8363f39b442851"
uuid = "69de0a69-1ddd-5017-9359-2bf0b02dc9f0"
version = "2.7.2"

[[deps.Pkg]]
deps = ["Artifacts", "Dates", "Downloads", "FileWatching", "LibGit2", "Libdl", "Logging", "Markdown", "Printf", "REPL", "Random", "SHA", "Serialization", "TOML", "Tar", "UUIDs", "p7zip_jll"]
uuid = "44cfe95a-1eb2-52ea-b672-e2afdf69b78f"
version = "1.9.2"

[[deps.PlutoDevMacros]]
deps = ["HypertextLiteral", "InteractiveUtils", "MacroTools", "Markdown", "Pkg", "Random", "TOML"]
git-tree-sha1 = "44b59480bdd690eb31b32f4ba3418e0731145cea"
uuid = "a0499f29-c39b-4c5c-807c-88074221b949"
version = "0.5.5"

[[deps.PlutoExtras]]
deps = ["AbstractPlutoDingetjes", "HypertextLiteral", "InteractiveUtils", "Markdown", "OrderedCollections", "PlutoDevMacros", "PlutoUI", "REPL"]
git-tree-sha1 = "4df3a485d53900720b052b3dc30225ed5ab4204b"
uuid = "ed5d0301-4775-4676-b788-cf71e66ff8ed"
version = "0.7.5"

[[deps.PlutoUI]]
deps = ["AbstractPlutoDingetjes", "Base64", "ColorTypes", "Dates", "FixedPointNumbers", "Hyperscript", "HypertextLiteral", "IOCapture", "InteractiveUtils", "JSON", "Logging", "MIMEs", "Markdown", "Random", "Reexport", "URIs", "UUIDs"]
git-tree-sha1 = "e47cd150dbe0443c3a3651bc5b9cbd5576ab75b7"
uuid = "7f904dfe-b85e-4ff6-b463-dae2292396a8"
version = "0.7.52"

[[deps.PrecompileTools]]
deps = ["Preferences"]
git-tree-sha1 = "9673d39decc5feece56ef3940e5dafba15ba0f81"
uuid = "aea7be01-6a6a-4083-8856-8a6e6704d82a"
version = "1.1.2"

[[deps.Preferences]]
deps = ["TOML"]
git-tree-sha1 = "7eb1686b4f04b82f96ed7a4ea5890a4f0c7a09f1"
uuid = "21216c6a-2e73-6563-6e65-726566657250"
version = "1.4.0"

[[deps.Printf]]
deps = ["Unicode"]
uuid = "de0858da-6303-5e67-8744-51eddeeeb8d7"

[[deps.REPL]]
deps = ["InteractiveUtils", "Markdown", "Sockets", "Unicode"]
uuid = "3fa0cd96-eef1-5676-8a61-b3b8758bbffb"

[[deps.Random]]
deps = ["SHA", "Serialization"]
uuid = "9a3f8284-a2c9-5f02-9a11-845980a1fd5c"

[[deps.Reexport]]
git-tree-sha1 = "45e428421666073eab6f2da5c9d310d99bb12f9b"
uuid = "189a3867-3050-52da-a836-e630ba90ab69"
version = "1.2.2"

[[deps.SHA]]
uuid = "ea8e919c-243c-51af-8825-aaa63cd721ce"
version = "0.7.0"

[[deps.Serialization]]
uuid = "9e88b42a-f829-5b0c-bbe9-9e923198166b"

[[deps.Sockets]]
uuid = "6462fe0b-24de-5631-8697-dd941f90decc"

[[deps.SparseArrays]]
deps = ["Libdl", "LinearAlgebra", "Random", "Serialization", "SuiteSparse_jll"]
uuid = "2f01184e-e22b-5df5-ae63-d93ebab69eaf"

[[deps.Statistics]]
deps = ["LinearAlgebra", "SparseArrays"]
uuid = "10745b16-79ce-11e8-11f9-7d13ad32a3b2"
version = "1.9.0"

[[deps.SuiteSparse_jll]]
deps = ["Artifacts", "Libdl", "Pkg", "libblastrampoline_jll"]
uuid = "bea87d4a-7f5b-5778-9afe-8cc45184846c"
version = "5.10.1+6"

[[deps.TOML]]
deps = ["Dates"]
uuid = "fa267f1f-6049-4f14-aa54-33bafae1ed76"
version = "1.0.3"

[[deps.Tar]]
deps = ["ArgTools", "SHA"]
uuid = "a4e569a6-e804-4fa4-b0f3-eef7a1d5b13e"
version = "1.10.0"

[[deps.Test]]
deps = ["InteractiveUtils", "Logging", "Random", "Serialization"]
uuid = "8dfed614-e22c-5e08-85e1-65c5234f0b40"

[[deps.Tricks]]
git-tree-sha1 = "aadb748be58b492045b4f56166b5188aa63ce549"
uuid = "410a4b4d-49e4-4fbc-ab6d-cb71b17b3775"
version = "0.1.7"

[[deps.URIs]]
git-tree-sha1 = "b7a5e99f24892b6824a954199a45e9ffcc1c70f0"
uuid = "5c2747f8-b7ea-4ff2-ba2e-563bfd36b1d4"
version = "1.5.0"

[[deps.UUIDs]]
deps = ["Random", "SHA"]
uuid = "cf7118a7-6976-5b1a-9a39-7adc72f591a4"

[[deps.Unicode]]
uuid = "4ec0a83e-493e-50e2-b9ac-8f72acf5a8f5"

[[deps.Zlib_jll]]
deps = ["Libdl"]
uuid = "83775a58-1f1d-513f-b197-d71354ab007a"
version = "1.2.13+0"

[[deps.libblastrampoline_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "8e850b90-86db-534c-a0d3-1478176c7d93"
version = "5.8.0+0"

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
# ╟─b0eb2aa1-f60e-49bf-b057-38c0ed002366
# ╠═28fa6890-3ce9-11ee-36bd-6371c1775e91
# ╠═76348a39-7dcb-4703-ba60-263fa84eae90
# ╟─19bddf77-7f36-40de-ac63-696aaf87556b
# ╠═bd6394e1-ca2b-4079-8b3a-710cef6b4dda
# ╟─fcec92a1-d776-462d-b25d-839d145d6594
# ╟─b8a055a9-7de3-48d3-9184-58e7bf432417
# ╟─48c7f30a-4f10-41aa-a3d6-740cfc3ad2c7
# ╠═68f705bb-9c8f-4eae-8a52-a390a3568152
# ╟─0cbfd57c-16f6-44b3-9983-44cb5802b88c
# ╟─b5bde02b-d4b3-43bc-b467-a5850d024a9f
# ╠═0c15167b-98e2-499d-bf5e-470994553f91
# ╠═b8f82bc0-db2e-410c-98af-3d7f2251c526
# ╟─49e6883f-4229-4225-bc05-3f97be286ae5
# ╟─9ac85b1b-9e76-4da6-a5ee-50ab5732c8e1
# ╠═bd4e372c-49ba-49a8-bab2-e056ccab6fc4
# ╠═b2322d22-c92d-4092-8a64-6ca2284beb77
# ╠═d3f48772-e700-4978-a03a-d6621cf44de9
# ╟─6d5e95b6-2223-4dd0-acd5-22b4ef6ae980
# ╠═089cbc8a-0f12-478a-beda-9f8144d823ef
# ╠═16e0a5ba-3571-4c58-9f57-8def8d57154a
# ╟─615a2e70-d714-49d0-98b6-60b951db1011
# ╠═6443c783-b6fb-4ce2-bfef-91c183c39c12
# ╠═68c956ef-aebc-4f80-96ad-6a3c0be6bdff
# ╠═cb46fdb3-41f4-4b51-ac5d-72e6b853b0be
# ╟─00000000-0000-0000-0000-000000000001
# ╟─00000000-0000-0000-0000-000000000002
