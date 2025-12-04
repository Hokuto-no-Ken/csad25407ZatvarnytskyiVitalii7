# -csad25407ZatvarnytskyiVitalii7
lab

## CI / Build Instructions

This repository includes a simple CI helper script and a GitHub Actions workflow that builds and tests the project automatically.

- `ci.sh` — A small shell script that configures, builds, and runs tests using CMake and CTest.
- `.github/workflows/ci.yml` — GitHub Actions workflow to run `ci.sh` on push and pull request events.

### Run locally
To run the same steps locally:

```bash
# Make the script executable and run it
chmod +x ./ci.sh
./ci.sh
```

You can pass a custom build directory as the first argument, for example:

```bash
./ci.sh out/build
```

Optional environment variables:
- `CMAKE_BUILD_TYPE` - default: `Release`.

If you want the script to do a fresh build, you can delete the build directory before running it.

