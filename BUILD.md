```fish
cd cef_artifacts
mkdir build
cmake -G "Unix Makefiles" -DCMAKE_BUILD_TYPE=Debug ..
 make -j8 cefclient cefsimple
cd ..
rm -rf build && mkdir build && cd build && cmake .. -G "Unix Makefiles" && make VERBOSE=1 > ../log.txt ; ..
```
