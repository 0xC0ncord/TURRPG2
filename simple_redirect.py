#!/usr/bin/env python3

import http.server, socketserver
import urllib.parse
import os
import signal

PORT = 8000
ALLOWED_EXTENSIONS = ('ukx', 'ut2', 'uax', 'usx', 'u', 'utx')
ASSET_DIRS = ('Animations', 'Maps', 'Sounds', 'StaticMeshes', 'System', 'Textures')

USE_COMPRESSION = True
TEMP_COMPRESSED_DIR = ".redirect"

import subprocess #TODO get rid of this when we use zlib
UCC_PATH = "System/ucc.exe"

#COMPRESS_OBJ = None

PROCESSING_FILES = []

class UT2K4RedirectHandler(http.server.SimpleHTTPRequestHandler):

    # Compress a file, 1Gb at a time
    def compress_file(self, infilepath: str, outfilepath: str) -> None:
        global PROCESSING_FILES

        print("Compressing file {} to {}".format(infilepath, outfilepath))

        # Append this file to files that we are currently compressing
        # This makes any further requests for it wait until it is complete
        PROCESSING_FILES.append(infilepath)

        # FIXME temporary workaround for zlib not cooperating
        subprocess.run(["wine", UCC_PATH, "compress", "../{}".format(infilepath).replace("/", "\\")], stdout=subprocess.PIPE, stderr=subprocess.PIPE)
        subprocess.run(["mv", "{}.uz2".format(infilepath), outfilepath], stdout=subprocess.PIPE, stderr=subprocess.PIPE)

        # TODO
        # Open this file
        #infile = open(infilepath, 'rb')

        # Open the output file
        #outfile = open(outfilepath, 'wb+')

        # Get input file's total size
        #infile.seek(0, 2)
        #size_total = infile.tell()

        # Seek back to beginning
        #infile.seek(0)

        # Start compressing and writing data, 1Gb at a time
        #data = bytes()
        #read = 0
        #size = 1073741824 # 1Gb
        #while read < size_total:
        #    outfile.write(COMPRESS_OBJ.compress(infile.read(size)))
        #    read = read + size
        #outfile.write(COMPRESS_OBJ.flush())

        # Close handles
        #infile.close()
        #outfile.close()

        # Remove this file from the processing list
        PROCESSING_FILES.remove(infilepath)


    def do_GET(self) -> None:

        # Parse query data to find out what was requested
        parsedParams = urllib.parse.urlparse(self.path)

        # Only respond if the requested file ends with an allowed file extension
        if not parsedParams.path.endswith(ALLOWED_EXTENSIONS) and not parsedParams.path.endswith('uz2'):
            print("Request did not end with an allowed file extension; sending 404 response.")
            self.send_response(404)
            self.end_headers()
            return

        # Only respond to the 'Unreal' user-agent
        if self.headers.get('User-Agent') != "Unreal":
            print("Request did not contain 'User-Agent: Unreal' header; sending 404 response.")
            self.send_response(404)
            self.end_headers()
            return

        # Only respond if the client sends a 'Connection: close'
        if self.headers.get('Connection') != "close":
            print("Request did not contain 'Connection: close' header; sending 404 response.")
            self.send_response(404)
            self.end_headers()
            return

        # Unquote the requested path before looking in the filesystem
        filepath = urllib.parse.unquote(parsedParams.path)

        if (filepath.endswith('.uz2') and not USE_COMPRESSION) or (not filepath.endswith('.uz2') and USE_COMPRESSION):
            # Can't do it
            print("Request for compressed/uncompressed file did not match configured mode.")
            self.send_response(404)
            self.end_headers()
            return

        if not USE_COMPRESSION:
            # See if the file requested exists
            if os.access('.' + os.sep + filepath, os.R_OK):
                # File exists, serve it up
                http.server.SimpleHTTPRequestHandler.do_GET(self);
            else:
                # Try to find out where this file lives
                foundIt = False
                for asset_dir in ASSET_DIRS:
                    if os.access('.' + os.sep + asset_dir + os.sep + filepath, os.R_OK):
                        foundIt = True
                        self.send_response(200)
                        self.end_headers()
                        # Found it, serve it up
                        with open('.' + os.sep + asset_dir + os.sep + filepath, 'rb') as fp:
                            self.copyfile(fp, self.wfile)
                            break
                if not foundIt:
                    # Didn't find it
                    self.send_response(404)
                    self.end_headers()
        else:
            # Check our temporary directory for the file in its compressed form if it exists
            if os.access(TEMP_COMPRESSED_DIR + os.sep + filepath, os.R_OK):
                # Serve it up
                http.server.SimpleHTTPRequestHandler.do_GET(self);
            else:
                # Need to find the uncompressed file first
                uncomp_filepath = filepath[:-len('.uz2')]

                # See if this file is already being compressed at this time
                if filepath in PROCESSING_FILES:
                    # Wait for it and then serve it up
                    while filepath in PROCESSING_FILES:
                        time.sleep(1)
                    # It's done
                    self.send_response(200)
                    self.end_headers()
                    # Serve it up
                    try:
                        with open(TEMP_COMPRESSED_DIR + os.sep + filepath, 'rb') as fp:
                            self.copyfile(fp, self.wfile)
                    except BrokenPipeError:
                        # Something went horribly wrong... should delete the file...
                        subprocess.run(["rm", "-f", TEMP_COMPRESSED_DIR + os.sep + filepath])
                    finally:
                        return

                foundIt = False
                for asset_dir in ASSET_DIRS:
                    if os.access('.' + os.sep + asset_dir + os.sep + uncomp_filepath, os.R_OK):
                        foundIt = True
                        # Found it, so let's compress it
                        self.compress_file('.' + os.sep + asset_dir + os.sep + uncomp_filepath, TEMP_COMPRESSED_DIR + os.sep + filepath)
                        self.send_response(200)
                        self.end_headers()
                        # Serve it up
                        try:
                            with open(TEMP_COMPRESSED_DIR + os.sep + filepath, 'rb') as fp:
                                self.copyfile(fp, self.wfile)
                        except BrokenPipeError:
                            # Something went horribly wrong... should delete the file...
                            subprocess.run(["rm", "-f", TEMP_COMPRESSED_DIR + os.sep + filepath])
                        finally:
                            return
                if not foundIt:
                    # Didn't find it
                    self.send_response(404)
                    self.end_headers()


# Ready, set, go!
def run() -> None:
    global USE_COMPRESSION
    global TEMP_COMPRESSED_DIR
    #global COMPRESS_OBJ

    def clean_up() -> None:
        httpd.shutdown()
        if USE_COMPRESSION:
            shutil.rmtree(TEMP_COMPRESSED_DIR)

    signal.signal(signal.SIGTERM, clean_up)

    try:
        # Setup and bind
        Handler = UT2K4RedirectHandler
        httpd = socketserver.TCPServer(("", PORT), Handler)
    except OSError:
        return

    try:
        # Set up things needed for compression if enabled
        if USE_COMPRESSION:
            try:
                if not os.path.exists(TEMP_COMPRESSED_DIR):
                    # Make our temporary holding area for compressed files
                    os.mkdir(TEMP_COMPRESSED_DIR)

                # TODO
                # Import zlib and get ourselves a compression object for working with them
                #import zlib
                #COMPRESS_OBJ = zlib.compressobj()

                # time is needed to sleep while waiting for compressed files
                import time

                # shutil needed to remove the temporary directory tree containing compressed files on cleanup
                import shutil
            except (OSError, ImportError):
                # Whatever, just disable compression
                USE_COMPRESSION = False

        # Start
        httpd.serve_forever()
    except:
        # Clean up
        clean_up()

# Main
if __name__ == "__main__":
    import argparse

    # Setup arguments
    parser = argparse.ArgumentParser(description="A simple UT2004 redirect server.")
    parser.add_argument('-d', action='store', dest='serve_dir', help="Set the base directory to serve files.")
    parser.add_argument('-c', action='store_true', dest='compression', help="Compress files to '.uz2' before serving.")
    parser.add_argument('--no-daemonize', '-n', action='store_true', dest='no_daemonize', help="Run in the foreground.")
    args = parser.parse_args()

    # If running in foreground, go ahead
    if args.no_daemonize:
        if args.serve_dir is not None:
            os.chdir(args.serve_dir + os.sep)

        USE_COMPRESSION = args.compression

        run()
    # Else fork ourselves running in the background
    else:
        import subprocess
        cmd = ['python3', __file__]
        if args.serve_dir is not None:
            cmd += ['-d', args.serve_dir]
        if args.compression:
            cmd += ['-c']
        cmd += ['-n']
        proc = subprocess.Popen(cmd)

        # Return the PID
        print(proc.pid)
