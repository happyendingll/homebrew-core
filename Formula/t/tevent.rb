class Tevent < Formula
  desc "Event system based on the talloc memory management library"
  homepage "https://tevent.samba.org"
  url "https://www.samba.org/ftp/tevent/tevent-0.17.3.tar.gz"
  sha256 "8eaa1b1b8d3c36ce8ddeae6d79c9a05360dcba5930115112c078415bcbe0d16d"
  license "LGPL-3.0-or-later"
  compatibility_version 1

  livecheck do
    url "https://www.samba.org/ftp/tevent/"
    regex(/href=.*?tevent[._-]v?(\d+(?:\.\d+)+)\.t/i)
  end

  bottle do
    root_url "https://github.com/happyendingll/intel-bottles/releases/download/bottles-warm-3"
    sha256 cellar: :any, sequoia: "a438372dd63afb3014aba03d1cfb2baa60d7a06aa0e196c58551df9a9646bc98"
  end

  depends_on "cmocka" => :build
  depends_on "pkgconf" => :build
  depends_on "talloc"

  uses_from_macos "python" => :build

  deny_network_access!

  def install
    system "./configure", "--bundled-libraries=NONE",
                          "--disable-python",
                          "--disable-rpath",
                          "--prefix=#{prefix}"
    system "make", "install"
  end

  test do
    # https://tevent.samba.org/tevent_events.html#Immediate
    (testpath/"test.c").write <<~C
      #include <stdio.h>
      #include <unistd.h>
      #include <tevent.h>
      struct info_struct {
        int counter;
      };
      static void foo(struct tevent_context *ev, struct tevent_immediate *im, void *private_data) {
        struct info_struct *data = talloc_get_type_abort(private_data, struct info_struct);
        printf("Data value: %d\\n", data->counter);
      }
      int main (void) {
        struct tevent_context *event_ctx;
        TALLOC_CTX *mem_ctx;
        struct tevent_immediate *im;
        printf("INIT\\n");
        mem_ctx = talloc_new(NULL);
        event_ctx = tevent_context_init(mem_ctx);
        struct info_struct *data = talloc(mem_ctx, struct info_struct);
        // setting up private data
        data->counter = 1;
        // first immediate event
        im = tevent_create_immediate(mem_ctx);
        if (im == NULL) {
          fprintf(stderr, "FAILED\\n");
          return EXIT_FAILURE;
        }
        tevent_schedule_immediate(im, event_ctx, foo, data);
        tevent_loop_wait(event_ctx);
        talloc_free(mem_ctx);
        return 0;
      }
    C

    system ENV.cc, "test.c", "-o", "test", "-L#{lib}", "-ltevent", "-L#{formula_opt_lib("talloc")}", "-ltalloc"
    system "./test"
  end
end
