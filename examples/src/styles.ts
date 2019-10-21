import { StyleSheet } from 'react-native';

export default StyleSheet.create({
  container: {
    flex: 1,
    alignItems: 'center',
    justifyContent: 'center',
    backgroundColor: '#fff'
  },

  item: {
    flexDirection: 'row',
    alignItems: 'center',
    marginBottom: 10
  },

  title: {
    marginBottom: 20,
    fontSize: 24
  },

  link: {
    marginBottom: 5,
    fontSize: 16,
    color: 'blue',
    textDecorationStyle: 'solid',
    textDecorationLine: 'underline'
  },

  input: {
    height: 40,
    width: 240,
    borderWidth: 1,
    borderColor: 'grey'
  },

  border: {
    borderColor: 'red',
    borderWidth: 1
  }
});
