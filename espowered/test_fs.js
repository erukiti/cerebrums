(function () {
    var Dummy, FS, assert, sinon;
    assert = require('power-assert');
    sinon = require('sinon');
    FS = require('../src/fs.coffee');
    Dummy = function () {
        function Dummy() {
        }
        Dummy.prototype.blobWrite = function (hash, content, func) {
            assert(assert._expr(assert._capt(assert._capt(hash, 'arguments/0/left') === '4cac15dfacf86b494af5f22ea6bdb24e1223bf2ef2d6718313a550ea290cda75', 'arguments/0'), {
                content: 'assert(hash === "4cac15dfacf86b494af5f22ea6bdb24e1223bf2ef2d6718313a550ea290cda75")',
                filepath: 'test_fs.coffee',
                line: 8
            }));
            assert(assert._expr(assert._capt(assert._capt(content, 'arguments/0/left') === 'hogefuga', 'arguments/0'), {
                content: 'assert(content === "hogefuga")',
                filepath: 'test_fs.coffee',
                line: 9
            }));
            return func();
        };
        Dummy.prototype.metaWrite = function () {
        };
        return Dummy;
    }();
    describe('FS', function () {
        return it('#create', function () {
            var dummy, fs;
            dummy = new Dummy();
            return fs = new FS(dummy);
        });
    });
}.call(this));
//# sourceMappingURL=data:application/json;base64,eyJ2ZXJzaW9uIjozLCJzb3VyY2VzIjpbInRlc3RfZnMuY29mZmVlIl0sIm5hbWVzIjpbXSwibWFwcGluZ3MiOiJBQUFBLENBQUEsWUFBQTtBQUFBLElBQUEsSUFBQSxLQUFBLEVBQUEsRUFBQSxFQUFBLE1BQUEsRUFBQSxLQUFBLENBQUE7QUFBQSxJQUFBLE1BQUEsR0FBUyxPQUFBLENBQVEsY0FBUixDQUFULENBQUE7QUFBQSxJQUNBLEtBQUEsR0FBUSxPQUFBLENBQVEsT0FBUixDQUFSLENBREE7QUFBQSxJQUdBLEVBQUEsR0FBSyxPQUFBLENBQVEsa0JBQVIsQ0FBTCxDQUhBO0FBQUEsSUFLTSxLQUFBLEdBQUEsWUFBQTtBQUFBO1NBQUE7QUFBQSx3QkFDSixZQUFXLFVBQUMsSUFBRCxFQUFPLE9BQVAsRUFBZ0IsSUFBaEIsRUFBQTtBQUFBLFlBQ1QsTUFBQSxDQUFPLE1BQUEsQ0FBQSxLQUFBLENBQUEsTUFBQSxDQUFBLEtBQUEsQ0FBQSxNQUFBLENBQUEsS0FBQSxDQUFBLElBQUEsMEJBQVEsa0VBQVI7QUFBQSxnQkFBQSxPQUFBO0FBQUEsZ0JBQUEsUUFBQTtBQUFBLGdCQUFBLElBQUE7QUFBQSxjQUFQLEVBRFM7QUFBQSxZQUVULE1BQUEsQ0FBTyxNQUFBLENBQUEsS0FBQSxDQUFBLE1BQUEsQ0FBQSxLQUFBLENBQUEsTUFBQSxDQUFBLEtBQUEsQ0FBQSxPQUFBLDBCQUFXLFVBQVg7QUFBQSxnQkFBQSxPQUFBO0FBQUEsZ0JBQUEsUUFBQTtBQUFBLGdCQUFBLElBQUE7QUFBQSxjQUFQLEVBRlM7QUFBQSxtQkFHVCxJQUFBLEdBSFM7QUFBQSxVQURQO0FBQUEsd0JBTUosWUFBVyxZQUFBO0FBQUEsVUFOUDtBQUFBLHFCQUFBO0FBQUEsS0FBQSxFQUFBLENBTE47QUFBQSxJQWNBLFFBQUEsQ0FBUyxJQUFULEVBQWUsWUFBQTtBQUFBLGVBQ2IsRUFBQSxDQUFHLFNBQUgsRUFBYyxZQUFBO0FBQUEsWUFDWixJQUFBLEtBQUEsRUFBQSxFQUFBLENBRFk7QUFBQSxZQUNaLEtBQUEsR0FBWSxJQUFBLEtBQUEsRUFBWixDQURZO0FBQUEsbUJBRVosRUFBQSxHQUFTLElBQUEsRUFBQSxDQUFHLEtBQUgsRUFGRztBQUFBLFNBQWQsRUFEYTtBQUFBLEtBQWYsRUFkQTtBQUFBLENBQUEsS0FBQSxLQUFBIiwic291cmNlc0NvbnRlbnQiOlsiYXNzZXJ0ID0gcmVxdWlyZSAncG93ZXItYXNzZXJ0J1xuc2lub24gPSByZXF1aXJlICdzaW5vbidcblxuRlMgPSByZXF1aXJlICcuLi9zcmMvZnMuY29mZmVlJ1xuXG5jbGFzcyBEdW1teVxuICBibG9iV3JpdGU6IChoYXNoLCBjb250ZW50LCBmdW5jKSAtPlxuICAgIGFzc2VydCBoYXNoID09IFwiNGNhYzE1ZGZhY2Y4NmI0OTRhZjVmMjJlYTZiZGIyNGUxMjIzYmYyZWYyZDY3MTgzMTNhNTUwZWEyOTBjZGE3NVwiXG4gICAgYXNzZXJ0IGNvbnRlbnQgPT0gXCJob2dlZnVnYVwiXG4gICAgZnVuYygpXG5cbiAgbWV0YVdyaXRlOiAoKSAtPlxuXG5cbmRlc2NyaWJlICdGUycsIC0+XG4gIGl0ICcjY3JlYXRlJywgLT5cbiAgICBkdW1teSA9IG5ldyBEdW1teSgpXG4gICAgZnMgPSBuZXcgRlMoZHVtbXkpXG4gICAgIyBhc3NlcnQgZnMuY3JlYXRlKFwiaG9nZWZ1Z2FcIikgPT0gXCJob2dlXCJcbiJdLCJmaWxlIjoidGVzdF9mcy5qcyIsInNvdXJjZVJvb3QiOiIvc291cmNlLyJ9