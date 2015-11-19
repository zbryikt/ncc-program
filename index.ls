angular.module \main, <[]>
  ..controller \main, <[$scope $http]> ++ ($scope, $http) ->
    $scope.channels = []
    $http do
      url: \data/104-11-02.json
      method: \GET
    .success (data) ->
      $scope.channels = []
      ret = {}
      for item in data
        ret[][item.1].push item
      for k,v of ret => 
        $scope.channels.push {name: k, list: v}
        v.sort (a,b) -> if a[4] > b[4} => 1 else if a[4] == b[4] => 0 else -1
