<?php
include 'header.php';
?>

<div class="intro-section-simple">
    <div class="container-fluid">
        <div class="flex md:flex-row md:px-10 lg:p-6 pb-20 items-center md:space-x-36 flex-col-reverse">
            <div class="text-left md:mt-10 lg:mt-0 mt-0 lg:pl-24">
                <a href="" class="flex justify-start space-x-3 items-center text-primary-600 hover:underline font-semibold mb-4 h-12">
                    <svg xmlns="http://www.w3.org/2000/svg" class="h-5 w-5 inline-block" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M10 19l-7-7m0 0l7-7m-7 7h18" />
                    </svg>
                    <div>Back to Releases</div>
                </a>
                <h2 class="font-bold pb-6">OCaml 4.12.0</h2>
                <div class="text-lg text-body-400">This page describes OCaml version <strong class="text-black">4.12.0</strong>, released on 2021-02-24. Go here for a list of all releases.</div>
                <div class="text-lg text-body-400 mt-6">This release is available as an <a href="" class="text-primary-600 hover:underline">OPAM</a> switch.</div>
            </div>
        </div>
    </div>
</div>
<div class="bg-white">
    <div class="py-10 lg:py-28">
        <div class="container-fluid">
            <div class="prose lg:prose-lg mx-auto max-w-5xl">
                <h3 class="font-bold text-body-600">What's new</h3>
                <div class="space-y-10">
                    <p>Some of the highlights in OCaml 4.12.0 are:</p>
                    <ul>
                        <li>Major progress in reducing the difference between the mainline and multicore runtime</li>
                        <li> A new configuration option ocaml-option-nnpchecker which emits an alarm when the garbage collector finds out-of-heap pointers that could cause a crash in the multicore runtime</li>
                        <li> Support for macOS/arm64</li>
                        <li>Many quality of life improvements</li>
                        <li>Many bug fixes</li>
                    </ul>
                    <p>
                        For a comprehensive list of changes and details on all new features, bug fixes, optimizations, etc., please consult the <a href="" class="text-primary-600 hover:underline">changelog</a> .
                    </p>
                    <div class="divider flex justify-center space-x-5">
                        <span class="rounded-full bg-gray-200 block"></span>
                        <span class="rounded-full bg-gray-200 block"></span>
                        <span class="rounded-full bg-gray-200 block"></span>
                    </div>

                    <h4>Configuration options</h4>


                </div>
                <p>The configuration of the installed opam switch can be tuned with the following options:</p>

                <ul>
                    <li>ocaml-option-32bit: set OCaml to be compiled in 32-bit mode for 64-bit Linux and OS X hosts</li>
                    <li>ocaml-option-afl: set OCaml to be compiled with afl-fuzz instrumentation</li>
                    <li>ocaml-option-bytecode-only: compile OCaml without the native-code compiler</li>
                    <li>ocaml-option-default-unsafe-string: set OCaml to be compiled without safe strings by default</li>
                    <li>ocaml-option-flambda: set OCaml to be compiled with flambda activated</li>
                    <li>ocaml-option-fp: set OCaml to be compiled with frame-pointers enabled</li>
                    <li>ocaml-option-musl: set OCaml to be compiled with musl-gcc</li>
                    <li>ocaml-option-nnp : set OCaml to be compiled with --disable-naked-pointers</li>
                    <li>ocaml-option-nnpchecker: set OCaml to be compiled with --enable-naked-pointers-checker</li>
                    <li>ocaml-option-no-flat-float-array: set OCaml to be compiled with --disable-flat-float-array</li>
                    <li>ocaml-option-static :set OCaml to be compiled with musl-gcc -static</li>
                </ul>
                <p>For instance, one can install a switch with both `<strong>flambda</strong>` and the naked-pointer checker enabled with
                <p>
                <pre><code>opam switch create 4.12.0+flambda+nnpchecker --package=ocaml-variants.4.12.0+options,ocaml-option-flambda,ocaml-option-nnpchecker</code></pre>
            </div>
        </div>
    </div>
</div>

<?php
include 'footer.php';
?>