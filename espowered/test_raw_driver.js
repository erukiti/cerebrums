(function () {
    var RawDriver, assert, sinon;
    assert = require('power-assert');
    sinon = require('sinon');
    RawDriver = require('../src/raw_driver.coffee');
    describe('RawDriver', function () {
        return it('#blobWrite', function () {
            var dummyObservable, mock, observable, rawDriver, rxfs;
            dummyObservable = {};
            rxfs = {
                writeFile: function () {
                    return null;
                }
            };
            mock = sinon.mock(rxfs);
            mock.expects('writeFile').once().withExactArgs('path', 'hoge').returns(dummyObservable);
            rawDriver = new RawDriver(rxfs);
            observable = rawDriver.blobWrite('path', 'hoge');
            assert(assert._expr(assert._capt(assert._capt(observable, 'arguments/0/left') === assert._capt(dummyObservable, 'arguments/0/right'), 'arguments/0'), {
                content: 'assert(observable === dummyObservable)',
                filepath: 'test_raw_driver.coffee',
                line: 17
            }));
            return mock.verify();
        });
    });
}.call(this));
//# sourceMappingURL=data:application/json;base64,eyJ2ZXJzaW9uIjozLCJzb3VyY2VzIjpbInRlc3RfcmF3X2RyaXZlci5jb2ZmZWUiXSwibmFtZXMiOltdLCJtYXBwaW5ncyI6IkFBQUEsQ0FBQSxZQUFBO0FBQUEsSUFBQSxJQUFBLFNBQUEsRUFBQSxNQUFBLEVBQUEsS0FBQSxDQUFBO0FBQUEsSUFBQSxNQUFBLEdBQVMsT0FBQSxDQUFRLGNBQVIsQ0FBVCxDQUFBO0FBQUEsSUFDQSxLQUFBLEdBQVEsT0FBQSxDQUFRLE9BQVIsQ0FBUixDQURBO0FBQUEsSUFHQSxTQUFBLEdBQVksT0FBQSxDQUFRLDBCQUFSLENBQVosQ0FIQTtBQUFBLElBS0EsUUFBQSxDQUFTLFdBQVQsRUFBc0IsWUFBQTtBQUFBLGVBQ3BCLEVBQUEsQ0FBRyxZQUFILEVBQWlCLFlBQUE7QUFBQSxZQUNmLElBQUEsZUFBQSxFQUFBLElBQUEsRUFBQSxVQUFBLEVBQUEsU0FBQSxFQUFBLElBQUEsQ0FEZTtBQUFBLFlBQ2YsZUFBQSxHQUFrQixFQUFsQixDQURlO0FBQUEsWUFHZixJQUFBLEdBQU87QUFBQSxnQkFBQyxTQUFBLEVBQVcsWUFBQTtBQUFBLDJCQUFHLEtBQUg7QUFBQSxpQkFBWjtBQUFBLGFBQVAsQ0FIZTtBQUFBLFlBSWYsSUFBQSxHQUFPLEtBQUEsQ0FBTSxJQUFOLENBQVcsSUFBWCxDQUFQLENBSmU7QUFBQSxZQUtmLElBQUEsQ0FBSyxPQUFMLENBQWEsV0FBYixFQUEwQixJQUExQixHQUFpQyxhQUFqQyxDQUErQyxNQUEvQyxFQUF1RCxNQUF2RCxFQUErRCxPQUEvRCxDQUF1RSxlQUF2RSxFQUxlO0FBQUEsWUFPZixTQUFBLEdBQWdCLElBQUEsU0FBQSxDQUFVLElBQVYsQ0FBaEIsQ0FQZTtBQUFBLFlBUWYsVUFBQSxHQUFhLFNBQUEsQ0FBVSxTQUFWLENBQW9CLE1BQXBCLEVBQTRCLE1BQTVCLENBQWIsQ0FSZTtBQUFBLFlBVWYsTUFBQSxDQUFPLE1BQUEsQ0FBQSxLQUFBLENBQUEsTUFBQSxDQUFBLEtBQUEsQ0FBQSxNQUFBLENBQUEsS0FBQSxDQUFBLFVBQUEsMEJBQWMsTUFBQSxDQUFBLEtBQUEsQ0FBQSxlQUFBLHNCQUFkO0FBQUEsZ0JBQUEsT0FBQTtBQUFBLGdCQUFBLFFBQUE7QUFBQSxnQkFBQSxJQUFBO0FBQUEsY0FBUCxFQVZlO0FBQUEsbUJBWWYsSUFBQSxDQUFLLE1BQUwsR0FaZTtBQUFBLFNBQWpCLEVBRG9CO0FBQUEsS0FBdEIsRUFMQTtBQUFBLENBQUEsS0FBQSxLQUFBIiwic291cmNlc0NvbnRlbnQiOlsiYXNzZXJ0ID0gcmVxdWlyZSAncG93ZXItYXNzZXJ0J1xuc2lub24gPSByZXF1aXJlICdzaW5vbidcblxuUmF3RHJpdmVyID0gcmVxdWlyZSAnLi4vc3JjL3Jhd19kcml2ZXIuY29mZmVlJ1xuXG5kZXNjcmliZSAnUmF3RHJpdmVyJywgLT5cbiAgaXQgJyNibG9iV3JpdGUnLCAtPlxuICAgIGR1bW15T2JzZXJ2YWJsZSA9IHt9XG5cbiAgICByeGZzID0ge3dyaXRlRmlsZTogLT4gbnVsbH1cbiAgICBtb2NrID0gc2lub24ubW9jayhyeGZzKVxuICAgIG1vY2suZXhwZWN0cyhcIndyaXRlRmlsZVwiKS5vbmNlKCkud2l0aEV4YWN0QXJncyhcInBhdGhcIiwgXCJob2dlXCIpLnJldHVybnMoZHVtbXlPYnNlcnZhYmxlKVxuXG4gICAgcmF3RHJpdmVyID0gbmV3IFJhd0RyaXZlcihyeGZzKVxuICAgIG9ic2VydmFibGUgPSByYXdEcml2ZXIuYmxvYldyaXRlKFwicGF0aFwiLCBcImhvZ2VcIilcblxuICAgIGFzc2VydCBvYnNlcnZhYmxlID09IGR1bW15T2JzZXJ2YWJsZVxuXG4gICAgbW9jay52ZXJpZnkoKVxuXG4iXSwiZmlsZSI6InRlc3RfcmF3X2RyaXZlci5qcyIsInNvdXJjZVJvb3QiOiIvc291cmNlLyJ9